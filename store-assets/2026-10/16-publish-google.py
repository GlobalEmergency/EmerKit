"""Publish the authorized EmerKit listing using the repository's protected secret.

All replacements happen in one Google Play edit; any failure discards that edit.
No releases, tracks, binaries, privacy answers or access permissions are changed.
"""
import hashlib
import json
import os
from pathlib import Path
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

BASE=Path(__file__).resolve().parent
PACKAGE='online.globalemergency.emerkit'


def publish():
    metadata=json.loads((BASE/'17-metadata-to-publish.json').read_text(encoding='utf-8'))
    for locale in ['es-ES','en-US']:
        fields=metadata['googlePlay']['localizations'][locale]
        assert len(fields['title'])<=30 and len(fields['shortDescription'])<=80 and len(fields['fullDescription'])<=4000
        folder=BASE/('es' if locale=='es-ES' else 'en')
        assert len(list((folder/'android-phone').glob('*.png')))==6
        assert (folder/'banners/01-feature-dark.png').is_file()
    creds=service_account.Credentials.from_service_account_info(json.loads(os.environ['GOOGLE_PLAY_SERVICE_ACCOUNT_JSON']),scopes=['https://www.googleapis.com/auth/androidpublisher'])
    service=build('androidpublisher','v3',credentials=creds,cache_discovery=False)
    edits=service.edits()
    edit=edits.insert(packageName=PACKAGE,body={}).execute()['id']
    committed=False
    try:
        previous=edits.listings().list(packageName=PACKAGE,editId=edit).execute()
        (BASE/'18-google-before-upload.json').write_text(json.dumps(previous,ensure_ascii=False,indent=2),encoding='utf-8')
        existing={x['language']:x for x in previous.get('listings',[])}
        results=[]
        for locale in ['es-ES','en-US']:
            folder=BASE/('es' if locale=='es-ES' else 'en')
            fields=metadata['googlePlay']['localizations'][locale]
            body={'language':locale,**{k:fields[k] for k in ['title','shortDescription','fullDescription']}}
            if existing.get(locale,{}).get('video'): body['video']=existing[locale]['video']
            edits.listings().update(packageName=PACKAGE,editId=edit,language=locale,body=body).execute()
            for image_type,files in [('phoneScreenshots',sorted((folder/'android-phone').glob('*.png'))),('featureGraphic',[folder/'banners/01-feature-dark.png'])]:
                old=edits.images().list(packageName=PACKAGE,editId=edit,language=locale,imageType=image_type).execute()
                (BASE/f'18-google-{locale}-{image_type}-before.json').write_text(json.dumps(old,indent=2),encoding='utf-8')
                edits.images().deleteall(packageName=PACKAGE,editId=edit,language=locale,imageType=image_type).execute()
                for source in files:
                    edits.images().upload(packageName=PACKAGE,editId=edit,language=locale,imageType=image_type,media_body=MediaFileUpload(str(source),mimetype='image/png')).execute()
                after=edits.images().list(packageName=PACKAGE,editId=edit,language=locale,imageType=image_type).execute()
                assert len(after.get('images',[]))==len(files), image_type
                results.append({'locale':locale,'type':image_type,'count':len(files)})
            actual=edits.listings().get(packageName=PACKAGE,editId=edit,language=locale).execute()
            assert all(actual[k]==fields[k] for k in ['title','shortDescription','fullDescription'])
        edits.validate(packageName=PACKAGE,editId=edit).execute()
        result=edits.commit(packageName=PACKAGE,editId=edit,changesNotSentForReview=False).execute()
        committed=True
        report={'package':PACKAGE,'state':'COMMITTED_REVIEW_REQUESTED','result':result,'resources':results,'metadataSha256':hashlib.sha256((BASE/'17-metadata-to-publish.json').read_bytes()).hexdigest()}
        (BASE/'19-google-upload-result.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
        print(json.dumps(report))
    finally:
        if not committed: edits.delete(packageName=PACKAGE,editId=edit).execute()


if __name__=='__main__':
    publish()
