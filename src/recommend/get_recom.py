from recommender import RecommendModel
from mongodb import MongoModel
from flask import Flask, jsonify, request
from bson.objectid import ObjectId
from bson import json_util
from datetime import datetime
import logging
import json

app = Flask(__name__)
app.config['JSON_AS_ASCII'] = False

@app.route('/recom/<_id>')
def get_recom(_id):
    formatter = '%(levelname)s : %(asctime)s : %(message)s'
    logging.basicConfig(level=logging.INFO, format=formatter)
    _logger = logging.getLogger(__name__)

    f = open('config_mongo.json', 'r')
    _mongo_conf = json.load(f)
    hostName = str(_mongo_conf['host']) + ':' + str(_mongo_conf['port'])
    mongo = MongoModel(hostName, 'newsdb', 'article_col')
    _logger.info('%s', 'Finish Setup Mongodb')
    recom = RecommendModel()
    _logger.info('%s', 'Finish Setup RecommendModel')
    recom_items = recom.get_recom_items(_id)
    if recom_items:
        recom_records = [mongo.find_one(filter={'_id': ObjectId(recom_id)}) for recom_id in recom_items]
        for recom_record in recom_records:
            recom_record['_id'] = str(recom_record['_id'])
            # TODO: 2021-03-07T20:00:04+09:00に合わせる
            tm = datetime.strptime(recom_record['publishedAt'], '%Y-%m-%dT%H:%M:%S%z')
            recom_record['publishedAt'] = tm.strftime('%Y-%m-%d %H:%M')
            _logger.info('%s', 'recom_record[\'titles\']:' + recom_record['titles'])
    else:
        recom_records = None
    _logger.info('%s', 'Finish Load recom_items')
    return jsonify({'data': recom_records}) # json.dumps({'data': recom_records}, default=json_util.default)


if __name__ == "__main__":
    app.run(host='0.0.0.0')

    
