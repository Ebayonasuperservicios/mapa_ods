import json

from flask import request

from ..controller import controller
from ..service import InterrupcionesService
from ..repository import InterrupcionesRepository
from ..util.constants import API_ROOT_PATH

@controller.route(API_ROOT_PATH + 'interrupciones', methods=['GET'])
def interrupciones(interrupciones_service: InterrupcionesService, interrupciones_repository: InterrupcionesRepository):
    # ARGS
    anio = request.args.get('anio', default=0, type=str)
    mes = request.args.get('mes', default=0, type=str)
    empresa = request.args.get('empresa', default=0, type=str)
    causa = request.args.get('causa', default=0, type=str)
    return interrupciones_service.get_interrupciones(interrupciones_repository, anio, mes, empresa, causa)
