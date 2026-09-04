import os
import redis
import logging

# Configuración de logs para CloudWatch
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    # Variables de entorno
    redis_host = os.environ.get('REDIS_ENDPOINT')
    redis_port = int(os.environ.get('REDIS_PORT', 6379))
    environment = os.environ.get('ENVIRONMENT', 'DEV')
    
    # Flag dinámico recibido desde la orquestación de Step Functions
    execute_flush = event.get('execute_flush', False)
    
    logger.info(f"Iniciando validación Redis en {environment}. Target: {redis_host}")
    
    try:
        # FASE 1 y 2: Test de Red y Protocolo (Ping)
        # socket_timeout garantiza que no se quede colgado si la IP es inalcanzable
        r = redis.Redis(host=redis_host, port=redis_port, socket_timeout=5, decode_responses=True)
        
        if r.ping():
            logger.info("PING exitoso: Conectividad y protocolo Redis validados.")
        else:
            raise Exception("Redis conectó pero no respondió al comando PING.")
            
        # FASE 3: Chequeo de Contenido
        db_size = r.dbsize()
        logger.info(f"DBSIZE actual: {db_size} llaves en memoria.")
        
        # FASE 4: Saneamiento Condicional
        if db_size > 0:
            if execute_flush:
                logger.warning("Flag execute_flush es TRUE. Ejecutando FLUSHALL...")
                r.flushall()
                logger.info("FLUSHALL ejecutado correctamente.")
                return {
                    "status": "SUCCESS", 
                    "message": "Redis validado y limpiado exitosamente.", 
                    "action": "FLUSHED"
                }
            else:
                logger.info("Flag execute_flush es FALSE. Se omitió la limpieza.")
                return {
                    "status": "SUCCESS", 
                    "message": "Redis validado. Flush omitido por política de entorno.", 
                    "action": "VALIDATED_ONLY"
                }
        else:
            logger.info("La base de datos de Redis ya se encontraba vacía.")
            return {
                "status": "SUCCESS", 
                "message": "Redis validado y confirmación de memoria vacía.", 
                "action": "ALREADY_EMPTY"
            }
            
    except Exception as e:
        logger.error(f"Falla crítica en validación de Redis: {str(e)}")
        # Levantar la excepción permite que Step Functions capture el error (Catch) 
        # y rutee el flujo hacia la notificación SNS del War Room.
        raise Exception(f"RedisDRPError: {str(e)}")