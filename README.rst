InstantRst
===========

It's a kind of thing like instan-markdown-d_, but for 
reStructuredText and using python.

Install:
--------

1. Vundle `Rykka/InstantRst`
2. Python: `pip install flask flask-socketio docutils pygments`

Usage
-----

In rst buffer, 
Use ``:InstantRst`` to preview current buffer.

Use ``:StopInstantRst`` to stop Preview current buffer

You should open a browser with http://localhost:5676

**Options:**

    `g:instant_rst_slow`: preview rst fast or slow, default is 0.
    `g:instant_rst_browser`: preview rst with browser. default is ''.



Related
-------

You can use Riv.vim_ to write your rst documents.

.. _instan-markdown-d: https://github.com/suan/instant-markdown-d

.. _Riv.vim: https://github.com/Rykka/riv.vim
