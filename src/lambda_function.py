import os
import redis
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    redis_host = os.environ.get('REDIS_ENDPOINT')
    redis_port = int(os.environ.get('REDIS_PORT', 6379))
    environment = os.environ.get('ENVIRONMENT', 'DEV')
    
    # Flag dinámico para ejecución destructiva
    execute_flush = event.get('execute_flush', False)
    
    logger.info(f"Validando Redis en {environment}. Endpoint: {redis_host}")
    
    try:
        r = redis.Redis(host=redis_host, port=redis_port, socket_timeout=5, decode_responses=True)
        
        if r.ping():
            logger.info("PING exitoso. Conectividad validada.")
        else:
            raise Exception("Redis conectó pero no respondió a PING.")
            
        db_size = r.dbsize()
        logger.info(f"DBSIZE actual: {db_size} llaves en memoria.")
        
        if db_size > 0:
            if execute_flush:
                logger.warning("Flag execute_flush es TRUE. Ejecutando FLUSHALL...")
                r.flushall()
                return {"status": "SUCCESS", "message": "Limpieza exitosa.", "action": "FLUSHED"}
            else:
                return {"status": "SUCCESS", "message": "Validado. Flush omitido.", "action": "VALIDATED_ONLY"}
        else:
            return {"status": "SUCCESS", "message": "Redis ya estaba vacío.", "action": "ALREADY_EMPTY"}
            
    except Exception as e:
        logger.error(f"Error crítico en Redis: {str(e)}")
        raise Exception(f"RedisDRPError: {str(e)}")