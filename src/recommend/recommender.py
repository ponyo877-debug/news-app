import time
import re
import emoji
import requests
import json
import os
import tempfile
import logging
import numpy as np
from annoy import AnnoyIndex
from bert_juman import BertWithJumanModel
from google.cloud import storage



def elapsed_print(start_time, symbol):
    elapsed_time = time.time() - start_time
    print('{0} elapsed_time:{1}'.format(symbol, elapsed_time) + '[sec]')


class RecommendModel():

    def __init__(self, idx2idvec_fn='idx2idvec.npy', id2idx_fn='id2idx.npy', nns_fn='recom.ann', dim=768):

        client = storage.Client.from_service_account_json('config_gcp.json')
        bucket_name = 'recommender'
        formatter = '%(levelname)s : %(asctime)s : %(message)s'
        logging.basicConfig(level=logging.INFO, format=formatter)
        self._logger = logging.getLogger(__name__)
        self._logger.info('%s', 'Start Create RecommendModel')
        self.bucket = client.get_bucket(bucket_name)
        self.nns_index = AnnoyIndex(dim, 'angular')
        self.idx2idvec_fn = idx2idvec_fn
        self.id2idx_fn = id2idx_fn
        self.nns_fn = nns_fn
        self._logger.info('%s', 'Finish Create RecommendModel')

    def _arrange_title(self, tmp):
        tmp = ''.join(['' if c in emoji.UNICODE_EMOJI else c for c in tmp])
        tmp = re.sub(r'(\d)([,.])(\d+)', r'\1\3', tmp)
        tmp = re.sub(r'[wWｗ・…]+', '', tmp)
        tmp = re.sub(r'[■-♯!-/:-@[-`{-~【】]', r' ', tmp)
        # tmp = re.sub(r'https?://[\w/:%#\$&\?\(\)~\.=\+\-]+', '', tmp)
        # tmp = re.sub(r'\d+', '0', tmp)
        return tmp # .replace('\n', '')
    
    def _get_vec_via_cs(self, filename):
        blob = self.bucket.blob(filename)
        if blob.exists():
            return self._np_load_via_cs(filename)
        else:
            return {}
    
    def _save_nns_index(self, num_tree=10):
        self._logger.info('[Annoy] %s', 'Start Method of _save_nns_index')
        for idx, id_vec in self.idx2idvec.items():
            self._logger.info('[Annoy] %s', str(idx) + ": " + str(len(id_vec[1])) + ' \'s Start Method of _save_nns_index')
            self.nns_index.add_item(idx, id_vec[1])
        self._logger.info('[Annoy] %s', 'Finish Loop of add_item')
        self.nns_index.build(num_tree)
        self._logger.info('[Annoy] %s', 'Finish annoy build')
        tmp = tempfile.NamedTemporaryFile()
        self.nns_index.save(tmp.name)
        self._logger.info('[Annoy] %s', 'Finish annoy save')
        tmp.seek(0)
        blob = self.bucket.blob(self.nns_fn)
        blob.upload_from_filename(filename=tmp.name)
        self._logger.info('[Annoy] %s', 'Finish annoy cloud storage save')
        time.sleep(10)
        tmp.close()
    
    def _load_nns_index(self):
        tmp = tempfile.NamedTemporaryFile()
        blob = self.bucket.blob(self.nns_fn)
        blob.download_to_filename(tmp.name)
        tmp.seek(0)
        self.nns_index.load(tmp.name)
        tmp.close()

    def _np_save_via_cs(self, filename, obj):
        tmp = tempfile.NamedTemporaryFile()
        np.save(tmp, obj)
        tmp.seek(0)
        blob = self.bucket.blob(filename)
        blob.upload_from_filename(filename=tmp.name)
        tmp.close()

    def _np_load_via_cs(self, filename):
        tmp = tempfile.NamedTemporaryFile()
        blob = self.bucket.blob(filename)
        blob.download_to_filename(tmp.name)
        tmp.seek(0)
        vec = np.load(tmp.name, allow_pickle=True)[()]
        tmp.close()
        return vec

    def put_recom_items(self, idx_titles, model='Japanese_L-12_H-768_A-12_E-30_BPE'):
        self._logger.info('%s', 'Start Method of put_recom_items')
        self.id2idx = self._get_vec_via_cs(self.id2idx_fn)
        self.idx2idvec = self._get_vec_via_cs(self.idx2idvec_fn)

        bert = BertWithJumanModel(model)
        dic_len = len(self.idx2idvec)
        for idx, record in enumerate(idx_titles):
            self._logger.info('%s', str(idx) + ' th Start Method of get_sentence_embedding')
            modified_title = self._arrange_title(record['titles'])
            self._logger.info('%s', modified_title + ', ' + record['titles'])
            self.idx2idvec[idx + dic_len] = [str(record['_id']), bert.get_sentence_embedding(modified_title)]
            self.id2idx[str(record['_id'])] = idx + dic_len
        self._logger.info('%s', 'Finish Method of get_sentence_embedding')
        self._np_save_via_cs(self.idx2idvec_fn, self.idx2idvec)
        self._logger.info('%s', 'Finish Method of _np_save_via_cs for idx2idvec')
        self._np_save_via_cs(self.id2idx_fn, self.id2idx)
        self._logger.info('%s', 'Finish Method of _np_save_via_cs for id2idx')
        self._save_nns_index()
        self._logger.info('%s', 'Finish Method of put_recom_items')

    def _get_idx_from_id(self, _id):
        nns_idx = self.id2idx.get(_id)
        return nns_idx

    def get_recom_items(self, _id, num_close_items=10):
        self.id2idx = self._get_vec_via_cs(self.id2idx_fn)
        self.idx2idvec = self._get_vec_via_cs(self.idx2idvec_fn)
        
        self._logger.info('%s', 'Start Method of get_recom_items')
        target_idx = self._get_idx_from_id(_id)
        print('target_idx:', target_idx)
        if target_idx:
            self._load_nns_index()
            near_list, _ = self.nns_index.get_nns_by_item(target_idx, num_close_items, include_distances=True)
            print('near_list:', near_list)
            recom_items = [self.idx2idvec[idx][0] for idx in near_list]
        else:
            recom_items = None
        self._logger.info('%s', 'Finish Method of get_recom_items')
        return recom_items
