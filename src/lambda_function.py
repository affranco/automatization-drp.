import os
import redis
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    # Tomamos la URL completa que configuraste en Terraform (rediss://...)
    redis_url = os.environ.get('REDIS_ENDPOINT')
    environment = os.environ.get('ENVIRONMENT', 'DEV')
    
    # Flag dinámico para ejecución destructiva
    execute_flush = event.get('execute_flush', False)
    
    logger.info(f"Validando Redis en {environment}. URL: {redis_url}")
    
    try:
        # from_url procesa correctamente el rediss://, el host, el puerto y activa SSL
        r = redis.from_url(redis_url, socket_timeout=5, decode_responses=True)
        
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