# -*- encoding: utf-8 -*-

"""Create all Data-Base"""

import os

from app.main import (
        db, # SQLAlchemy Connector dB Object
        create_app
    )
from app.main.models import * # noqa: F401, F403

app = create_app(os.getenv("PROJECT_ENV_NAME") or "dev")

with app.app_context():
    # db.init_app(app)
    db.create_all()
