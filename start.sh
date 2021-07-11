source venv/bin/activate
pip3 install -r requirements.txt
gunicorn --workers=2 --threads=4 --bind=127.0.0.1:5000 app:app