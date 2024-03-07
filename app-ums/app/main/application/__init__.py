# -*- encoding: utf-8 -*-

"""
Application Layer of the REST-API

This directory hosts the `api` and `controller`, and is kept seperate
from other layers for security purpose. The new `flask` design
(https://github.com/ZenithClown/flask-docker-template) allows the use
of `BaseResource` that provides utility functions for a controller
object. Define a controller as:

```python
class ControllerName(BaseResource):
    '''docstring'''

    def __init__(self, *args, **kwargs):
        super().__init__()


    def get(self, *args, **kwargs):
        '''SELECT Statements for the Controller'''

        return self.formatter.get(data)


    def post(self, *args, **kwargs):
        '''UPDATE Statements for the Controller'''

        return self.formatter.post(msg)
```

Currently, the `utils.ResponseFormatter` is configured only with
`GET` and `POST` features, but others may be updated as required.

? `api` - specialized endpoints that wraps controller object
? `controller` - define base methods > relates to app/models
"""
