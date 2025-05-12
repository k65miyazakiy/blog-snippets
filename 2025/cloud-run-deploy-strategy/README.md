# Simple Web App for Cloud Run

Cloud Runで実行するためのシンプルなHello Worldウェブアプリケーションです。
dockerおよびgcloudコマンドが実行できることと、gcloudコマンドがGoogle Cloudに認証済みであることを前提にしています。

## Google Cloud Runへの各種デプロイ手順

初回デプロイや更新、クリーンアップに便利なスクリプトを提供しています。

```bash
./initial_deploy.sh # 初回デプロイ用。Artifact Registryのレポジトリ作成、イメージのデプロイとCloud Runサービスの作成を行います
./update_deploy.sh  # デプロイの更新用。 update_deploy.sh XXX とすることでWebサービスが Hello XXXと返すようになります。
                    # また、デフォルトでは新規リビジョンに対してはトラフィックを振り分けませんが、
                    # update_deploy.sh XXX 20などとすることで、この例では20%のトラフィックを新規リビジョンに振り分けるようにもデプロイできます。
./cleanup.sh        # Cloud Runのサービスを削除します
```
