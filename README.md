# JupyterLab Real-Time Collaboration

This repo contains a Docker-based demo of JupyterLab with real-time collaboration.

To run this demo using Docker:

```
docker run -p 8888:8888 start.sh jupyter lab --dev-mode --no-browser
```

Then open the URL that prints to the output. To play with real-time collaboration,
open the same notebook or text file in two separate browser tabs and edit away!