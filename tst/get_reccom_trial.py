import time
import re
import emoji


def elapsed_print(start_time, symbol):
    elapsed_time = time.time() - start_time
    print('{0} elapsed_time:{1}'.format(symbol, elapsed_time) + '[sec]')


file_name = 'matome_data.txt'

start_parse = time.time()
# Parse sentence, create List of lists of tokens
titles = open(file_name, 'r', encoding='utf-8')
X = []

for text1 in titles:
    # delete URL
    text2 = re.sub(r'https?://[\w/:%#\$&\?\(\)~\.=\+\-]+', '', text1)
    # delete emoji
    text3 = ''.join(['' if c in emoji.UNICODE_EMOJI else c for c in text2])
    # replace number
    tmp = re.sub(r'(\d)([,.])(\d+)', r'\1\3', text3)
    text4 = re.sub(r'\d+', '0', tmp)
    # replace 1byte symbol
    text5 = re.sub(r'[!-/:-@[-`{-~]', r' ', text4)
    # replace 2byte symbol(only block of 0x25A0-0x266F)
    title = re.sub(u'[■-♯]', ' ', text5)
    # print(title)
    X.append(title.replace('\n', ''))
elapsed_print(start_parse, 'start_parse')
# print('X[0]: ', X[0])
# print('X[3]: ', X[3])

'''
from gensim.models import FastText

start_fasttext = time.time()
# hyper parameters
num_features = 300  # fastText embedding dim
min_word_count = 10  # Minimum word count
context = 10  # Context window size

# learn fastText
w2v_model = FastText(size=num_features, sg=1, workers=-1, window=context, min_count=min_word_count)
w2v_model.build_vocab(titles_for_fasttext)
w2v_model.train(titles_for_fasttext, total_examples=w2v_model.corpus_count, epochs=w2v_model.epochs)
elapsed_print(start_fasttext, 'start_fasttext')



from sklearn.mixture import GaussianMixture
import scdv_class

start_scdv = time.time()
# hyper parameters
num_clusters = 30  # cluster num of GMM clustering
sparse_percentage = 0.01

# train SCDV
gmm = GaussianMixture(n_components=num_clusters, covariance_type="tied", init_params='kmeans', max_iter=50)
scdv_model = scdv_class.SCDV(w2v_model=w2v_model, sc_model=gmm, sparse_percentage=sparse_percentage)
scdv_model.precompute_word_topic_vector(titles_for_fasttext)
X = scdv_model.train(titles_for_fasttext)
elapsed_print(start_scdv, 'start_scdv')
'''

from annoy import AnnoyIndex

start_annoy = time.time()
# Build Annoy
f = 768
t_bert = AnnoyIndex(f, 'angular')

from bert_juman import BertWithJumanModel
bert = BertWithJumanModel("Japanese_L-12_H-768_A-12_E-30_BPE")

for i in range(len(X)):
    if i % 1 == 0:
        print("now: ", i)
    t_bert.add_item(i, bert.get_sentence_embedding(X[i]))

t_bert.build(10)  # 10 trees
t_bert.save('t_bert.ann')
elapsed_print(start_annoy, 'start_annoy')


u_scdv = AnnoyIndex(f, 'angular')
u_scdv.load('t_bert.ann')

start_execute = time.time()
for target in range(1, 10):
    print('Query%d  - title: %s' % (target, X[target]))
    k = 10
    near_list, dists = u_scdv.get_nns_by_item(target, k, include_distances=True)
    for i in range(1, k, 1):
        doc_idx = near_list[i]
        print('Rank:%d (dist:%.3f) - title: %s' % (i, dists[i], X[doc_idx]))
    print('\n')
elapsed_print(start_execute, 'start_execute')
