#!/usr/bin/env python3

import os
from pathlib import Path
import sys
import logging
import logging.handlers
from aoconfig import CFG

def setuplogs():
    # Get AO_DATA environment variable
    env_data = os.environ.get("AO_DATA")  

    if env_data:
        log_dir = os.path.join(Path(env_data).expanduser(), "logs")
    else:
        log_dir = os.path.join(os.path.expanduser("~"), ".autoortho-data-11", "logs")
    if not os.path.isdir(log_dir):
        os.makedirs(log_dir)

    log_level=logging.DEBUG if os.environ.get('AO_DEBUG') or CFG.general.debug else logging.INFO
    logging.basicConfig(
            #filename=os.path.join(log_dir, "autoortho.log"),
            level=log_level,
            handlers=[
                #logging.FileHandler(filename=os.path.join(log_dir, "autoortho.log")),
                logging.handlers.RotatingFileHandler(
                    filename=os.path.join(log_dir, "autoortho.log"),
                    maxBytes=10485760,
                    backupCount=5
                ),
                logging.StreamHandler() if sys.stdout is not None else logging.NullHandler()
            ]
    )
    log = logging.getLogger(__name__)
    log.info(f"Setup logs: {log_dir}, log level: {log_level}")
    log.info("ALLAN: env_data: " + str(env_data))
    log.info("ALLAN: log_dir: " + str(log_dir))

def _quiet_external_loggers():
    """Clamp noisy third-party loggers so the console stays readable."""
    import logging
    # Keep your own INFO/ERROR visible
    logging.getLogger().setLevel(logging.INFO)

    # Tame FUSE/refuse verbosity
    for name, level in [
        ("fuse", logging.WARNING),
        ("refuse", logging.WARNING),
        ("refuse.high", logging.ERROR),
    ]:
        lg = logging.getLogger(name)
        lg.setLevel(level)
        # prevent duplicate propagation up to root
        lg.propagate = False

import autoortho

if __name__ == "__main__":
    setuplogs()
    _quiet_external_loggers()
    autoortho.main()
