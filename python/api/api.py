import flask
import socket

from flask import request

app = flask.Flask(__name__)
app.config["DEBUG"] = True


@app.route('/', methods=['GET'])
def home():
    return "<div style=\"margin:10px;\"><h2 style=\"margin-bottom:10px;\">Opciones:</h2><h3><a href=\"/greetings\">greetings</a></h3><h3><a href=\"/square\">square</a></h3><div>"

@app.route('/greetings', methods=['GET'])
def greetings():
    return "<div style=\"margin:10px;\">Hello World! from " + socket.gethostname() + "<br/></br><a href=\"/\">Regresar</a></div>"

@app.route('/square', methods=['GET'])
def square():
    template = "<form action=\"/square\" method=\"get\"><code>Ingresa un n&uacute;mero para calcular su cuadrado: </code><input type=\"number\" name=\"x\" style=\"width:4rem;\" /><input type=\"submit\" value=\"Square\" style=\"margin-left:10px;\"/></form>"
    if 'x' in request.args:
        if request.args['x'] == '':
            return "<div style=\"margin:10px;\"><strong style=\"color: red;\">Debe ingresar un valor v&aacute;lido</strong><br/><br/>" + template + "</div>"
        x = int(request.args['x'])
        return "<div style=\"margin:10px;\">number: " + str(x) + ", square: " + str(x*x) + " <br/></br>" + template + "<br/><br/><a href=\"/\">Regresar</a><div>"
    else:
        return "<div style=\"margin:10px;\">" + template + "</div>"

app.run(host='0.0.0.0', port=5000)