from flask import Flask, render_template, request, url_for
from flask.ext.socketio import SocketIO, emit

app = Flask(__name__)
app.debug = True
app.config['SECRET_KEY'] = 'JO34h#F*$HFHA@#&('
socketio = SocketIO(app)

from docutils import core, io

import os, sys

def html_parts(input_string, source_path=None, destination_path=None,
               input_encoding='unicode', doctitle=True,
               initial_header_level=1):
    overrides = {'input_encoding': input_encoding,
                 'doctitle_xform': doctitle,
                 'initial_header_level': initial_header_level}
    parts = core.publish_parts(
        source=input_string, source_path=source_path,
        destination_path=destination_path,
        writer_name='html', settings_overrides=overrides)
    return parts


def html_body(input_string, source_path=None, destination_path=None,
              input_encoding='unicode', output_encoding='unicode',
              doctitle=True, initial_header_level=1):
    parts = html_parts(
        input_string=input_string, source_path=source_path,
        destination_path=destination_path,
        input_encoding=input_encoding, doctitle=doctitle,
        initial_header_level=initial_header_level)
    fragment = parts['html_body']
    if output_encoding != 'unicode':
        fragment = fragment.encode(output_encoding)
    return fragment


@app.route("/", methods=['GET','PUT','POST','DELETE'])
def index():
    if request.method == 'PUT' or request.method == 'POST':
        f = request.form['file']
        if os.path.isfile(f):
            with open(f,'r') as rst:
                d = html_body(rst.read().decode('utf8'))
            socketio.emit('updatingContent', {'HTML': d})
        else:
            raise "File Not Exists"
    if request.method == 'DELETE':
        socketio.emit('die', {'exit': 1})
        shutdown_server()

    return render_template('index.html')

def shutdown_server():
    exit = request.environ.get('werkzeug.server.shutdown')
    if exit is None:
        sys.exit()
    exit()

@socketio.on('my event')
def test_message(message):
    emit('my response', {'data': 'got it!'})

if __name__ == '__main__':
    socketio.run(app, port=5676)
