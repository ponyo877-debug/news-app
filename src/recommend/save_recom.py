from recommender import RecommendModel
from mongodb import MongoModel
import json
import logging



if __name__ == "__main__":

    formatter = '%(levelname)s : %(asctime)s : %(message)s'
    logging.basicConfig(level=logging.INFO, format=formatter)
    _logger = logging.getLogger(__name__)

    _logger.info('%s', 'Start Create Instance of RecommendModel')
    f = open('config_mongo.json', 'r')
    _mongo_conf = json.load(f)
    hostName = str(_mongo_conf['host']) + ':' + str(_mongo_conf['port'])
    mongo = MongoModel(hostName, 'newsdb', 'article_col')
    recom = RecommendModel()
    _logger.info('%s', 'Finish Create Instance of RecommendModel')

    target_items = mongo.find(filter={'acquired': False})
    recom.put_recom_items(target_items)
    mongo.update_many({'acquired': False}, {'$set':{'acquired': True}})
    _logger.info('%s', 'Finish Method of mongo.update_many')

