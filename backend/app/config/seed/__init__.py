# -*- encoding: utf-8 -*-

"""
Initialization of Database with SEED Values

The database (particularly the metadata tables) are seeded with
pre-loaded values like account type, sub-type etc. which is required
by the program to efficiently run.
"""

from sqlalchemy.exc import IntegrityError

from backend.main import session
from backend.app.config.seed.ams_metadata import * # noqa: F401, F403 # pyright: ignore[reportMissingImports]
from backend.app.config.seed.ums_metadata import * # noqa: F401, F403 # pyright: ignore[reportMissingImports]

def _seed() -> bool:
    for func in [account_types, account_subtypes, user_roles, user_rubroles]:
        try:
            with session.begin() as sess:
                sess.add_all(func())
                sess.commit()
        except IntegrityError as err:
            print(f"Aborting {func.__name__}, due to: {err}")
        except Exception:
            raise ValueError("Unable to Seed the Database. Aborting!")
    
    return True
