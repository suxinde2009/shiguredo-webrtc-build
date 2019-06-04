# WebRTC ライブラリ用ビルドツール

iOS と Android 向けの WebRTC ライブラリをビルドします。WebRTC ライブラリのビルドは複雑でわかりにくいです。
また WebRTC ライブラリのバージョンが上がるごとにビルド方法が変わることも多く、追従するのは現実的ではありませんでした。

このツールはもともと[株式会社時雨堂](https://shiguredo.jp)の社内ツールでしたが、
少しでも WebRTC ライブラリに追従する負荷を削減できればと思い公開することにしました。

## 注意

このビルドツールの主な目的は[株式会社時雨堂](https://shiguredo.jp)の製品である [WebRTC SFU Sora](https://sora.shiguredo.jp) の SDK 利用のために開発されています。
そのため、目的を越えた汎用的なビルドツールにする予定はありません。リソースの都合上、バグ報告以外の PR に対応できるとは限りませんのでご了承ください。

## 方針

Chrome の安定版のバージョンに合わせて追従していきます。 master ブランチやリリースブランチの HEAD への追従は行いません。

## ライセンス

以下に示す例外を覗いて、すべてのソースコードは Apache License Version 2.0 でライセンスされます。

例外は次のとおりです。

- libwebrtc (webrtc.org) のコードを元にしたファイルは webrtc.org と同様に BSD ライセンス(三条項)で
  ライセンスされます。

  - ライセンスファイル: https://webrtc.googlesource.com/src/+/master/LICENSE
  - 対象ファイル: `patch/` 以下のファイル
  - オリジナル: `config.json` の `_patches` にある `target`

- chromium のコードを本にしたファイルは chromium と同様に BSD ライセンス(三条項)で
  ライセンスされます。

  - ライセンスファイル: https://chromium.googlesource.com/chromium/src/+/master/LICENSE
  - 対象ファイル: `docker-aar/install-build-deps.sh`
  - オリジナル: M68 ブランチの
    https://chromium.googlesource.com/chromium/src/+/master/build/install-build-deps.sh

## ダウンロード

実行可能なビルドツールは [Releases](https://github.com/shiguredo/sora-webrtc-build/releases) からダウンロードできます (ビルド済みの WebRTC ライブラリではありません) 。
リポジトリを clone する必要はありません。

## ビルドのシステム条件

Android のビルドは Linux のみサポートされているため、一台の Mac で iOS/Android の両方のビルドはできません。

- iOS
  - Mac OS X 10.12.6+
  - Xcode 9.0+
  - Python 2.7
- Android
  - Ubuntu Linux 18.04 64bit
  - Python 2.7

## バージョン表記について

バージョンは「メジャー.マイナー.メンテナンス」で表します。

- メジャーバージョン: WebRTC ライブラリのリリースブランチ番号を表します。
- マイナーバージョン: WebRTC ライブラリのコミットポジション番号を表します。 コミットポジション番号とは WebRTC ライブラリでリビジョンごとに割り振られる数値です。 リリースブランチ作成時のコミットポジションは 1 であるため、マイナーバージョンは常に 1 から始まります。
- メンテナンスバージョン: WebRTC ライブラリ以外の変更を加えたときに上がります。

[6d56d2e](https://chromium.googlesource.com/external/webrtc/+/6d56d2ebf0e40bc73dee99093ac7c223ddc7b6e5) を例にすると、リリースブランチ番号が 59 、コミットポジション番号が 4 なので、バージョンは 59.4.x になります。

## 仕様

- 対応する WebRTC のバージョン: M66
- 対応するアーキテクチャ: arm64/armv7 (iOS), armeabi-v7a/arm64-v8a (Android)
- VP9 対応 (可否を指定可)
- (iOS) Bitcode 対応 (可否を指定可)

## 使い方 (iOS 向け)

``make`` にビルドしたい設定をターゲットに指定して実行します。 ``config`` ディレクトリ下のディレクトリ名をターゲットとして指定可能です。

例:

```
# config/ios-m73.10 以下の設定でビルドされます。
# ビルドされたライブラリは build/ios-m73.10/WebRTC.framework にあります。
$ make ios-m73.10
```

ターゲット名の ``ios-`` 以下はリリースブランチとコミットポジションを表します。ターゲット名が ``ios-m73.10`` であれば、「リリースブランチ M73 、コミットポジション 10 」をビルドします。

ビルドの成果物は ``build/ターゲット名`` ディレクトリ下に置かれます。 iOS アプリケーションで使うライブラリは ``WebRTC.framework`` です。 ``WebRTC.framework`` には、 libwebrtc に関連するライブラリのライセンスを記述したファイル ``LICENSE.md`` が含まれます。

### ビルドのみ行う

これらのターゲットは、ビルドの前にビルドツール ``depot_tools`` と libwebrtc のソースコードのダウンロード及び更新を行います。すでにダウンロード済みで、更新の必要もない場合は、ターゲット名の末尾に ``-nofetch`` を指定するとビルドのみを実行可能です。

例:

```
# ビルドのみ行います。ソースコードのダウンロードは行われません。
$ make ios-m73.10-nofetch
```

### アプリケーション開発向けのビルド

上記のターゲットで生成されるバイナリ (``WebRTC.framework``) は Bitcode を含みます。 Bitcode を含む ``WebRTC.framework`` のサイズは数百 MB を超えるので、 Bitcode を含まないバイナリに比べて、ビルドと実行までにかかる時間がかなり増えます。

ターゲット名に ``-develop`` をつけると、 Bitcode を含まないバイナリを生成します。ビルドと実行を頻繁に繰り返すアプリケーション開発時に利用してください。

## 使い方 (Android 向け)

``make`` にビルドしたい設定をターゲットに指定して実行します。 ``config`` ディレクトリ下のディレクトリ名をターゲットとして指定可能です。

例:

```
# config/android-m73.10 以下の設定でビルドされます。
# ビルドされたライブラリは build/android-m73.10/libwebrtc.aar にあります。
$ make android-m73.10
```

### ビルドのみ行う

これらのターゲットは、ビルドの前にビルドツール ``depot_tools`` と libwebrtc のソースコードのダウンロード及び更新を行います。すでにダウンロード済みで、更新の必要もない場合は、ターゲット名の末尾に ``-nofetch`` を指定するとビルドのみを実行可能です。

例:

```
# ビルドのみ行います。ソースコードのダウンロードは行われません。
$ make android-m73.10-nofetch
```

## Android ライブラリの Docker でのビルドについて

AAR(Android ARchive)ビルドは Docker 上でのビルドが可能です。
ただしビルドエラーのデバッグの際には、手順の詳細や Docker ではない環境でビルドする必要があるかもしれません。
その際は "使い方 (Android 向け)" を参照してください。

手順

1. `docker-aar/install-build-deps.sh` の変更
   - Ubuntu パッケージ依存まわりのエラーが出た場合には更新してください
     - 毎回更新する必要はあまりないと思います (断言はできません)
   - スクリプトは https://webrtc.org/native-code/development/ の手順で、対象のブランチを指定して
     `fetch`, `gclient sync` すると `src/build/` 以下に取得できます。
2. `make aar-<config-path>`
   - 例: `make aar-android-m73.10`


## Android ライブラリのビルドについて

- 実行時のシェルは Bash を推奨します。 Zsh だとビルドエラーになる場合がありました。

- ``gclient sync`` を実行すると、ソースコードのダウンロード中に Google Play Service クライアントライブラリのライセンス許諾を求められますが、 ``webrtc-build`` コマンドはユーザーがライセンスを許諾したものとして処理を続けます。ご注意ください。

## ビルドの設定

``config.json`` でビルドの設定が可能です。
リリースブランチやリビジョンを変更したときは、 ``update`` または ``all`` で既存のソースコードへの変更を破棄してから更新しておくとビルドの失敗を防げます。

- ``webrtc_branch``: リリースブランチ番号。

- ``webrtc_commit``: コミットポジション番号。 **ソースコードのダウンロードには影響しません。**

- ``webrtc_revision``: リビジョン番号。リリースブランチの取得後、指定したリビジョンをチェックアウトします。

- ``maint_version``: ``config.json`` 用のメンテナンスバージョン。ビルド設定を更新した場合などに変更してください。

- ``python``: Python のパス。 WebRTC のソースコードに含まれるビルドスクリプトで使われます。

- ``ios_arch``: iOS ライブラリでサポートするアーキテクチャ。 ['arm64', 'arm', 'x64', 'x86'] から複数選択可能です。ただし、シミュレーター向けのビルドはできますが、動作はサポートされていません。

- ``ios_targets``: iOS ライブラリのビルド対象。複数選択可能です。

  - ``framework``: フレームワーク

  - ``static``: 静的ライブラリ

- ``ios_bitcode``: Bitcode の可否。 Bitcode を有効にすると、ビルドしたバイナリのサイズが数百 MB になる可能性があります。

- ``android_arch``: Android ライブラリでサポートするアーキテクチャ。 ['armeabi-v7a', 'arm64-v8a', 'x86', 'x86_64'] から複数選択可能です。

- ``build_config``: ビルドの用途。複数選択可能です。

  - ``debug``: デバッグ用

  - ``release``: リリース用

- ``vp9``: VP9 の可否。

- ``apply_patch``: パッチの適用の可否。

- ``patches``: 適用するパッチのリスト。各パッチのフォーマットは次の要素を持つ辞書です。

  - ``patch``: 適用するパッチのパス。パッチは ``patch`` ディレクトリに置いてください。

  - ``target``: パッチを適用するファイル。 ``webrtc/src`` 以下のファイルを指定します。

## ビルド情報 (iOS)

ビルド時の情報は `build_info.json` に保存されます。フレームワークには ``build_info.json`` が含まれています。

- `webrtc_version` (string): WebRTC のリリースブランチ番号
- `webrtc_revision` (string): WebRTC のリビジョン番号

## トラブルシューティング

ビルドエラーの大半は depot_tools が原因である可能性が高いです。
エラーが出たら、まず次の処理を試してみてください。

- **(特に Android) シェルを Bash に変更する**

- ``./webrtc-build fetch`` を実行する

- ``webrtc`` ディレクトリで ``gclient runhooks`` を実行する

### depot_tools のコマンド (gclient など) を使いたい

``./webrtc-build fetch`` でダウンロードした depot_tools は ``webrtc/depot_tools`` にダウンロードされます。コマンド検索パスにディレクトリを追加します。

例: ``webrtc/src`` ディレクトリで depot_tools のコマンドを使う場合

```
export PATH=../depot_tools:$PATH
```

### ``./webrtc-build fetch``: 実行が途中で止まってしまった

再度 ``./webrtc-build fetch`` を実行してください。
``./webrtc-build fetch`` は何度実行しても問題ありません。

### ``./webrtc-build fetch``: ``stderr:error: Your local changes to the following files would be overwritten by checkout``

パッチの適用後に ``./webrtc-build fetch`` を実行すると、リポジトリに変更があるために指定のリビジョンをチェックアウトできずにエラーになります。
``./webrtc-build clean`` を実行して、リポジトリの変更を戻してから再度 ``./webrtc-build fetch`` を実行してください。

### ``./webrtc-build build``: ``stderr:.gclient file in parent directory XXX might not be the file you want to use``

``./webrtc-build fetch`` を実行してからもう一度試してください。

```
stderr:.gclient file in parent directory /home/shiguredo/sora-webrtc-build/webrtc might not be the file you want to use
stderr:gn.py: Could not find gn executable at: /home/shiguredo/sora-webrtc-build/webrtc/src/buildtools/linux64/gn
```

### ``./webrtc-build build``: ``Error: Command 'XXX' returned non-zero exit status 1 in XXX``

``./webrtc-build fetch`` を実行してからもう一度試してください。

```
________ running '/usr/bin/python src/third_party/binutils/download.py' in '/home/shiguredo/sora-webrtc-build/webrtc'
Downloading /home/shiguredo/sora-webrtc-build/webrtc/src/third_party/binutils/Linux_x64/binutils.tar.bz2
Traceback (most recent call last):
  File "src/third_party/binutils/download.py", line 130, in <module>
    sys.exit(main(sys.argv[1:]))
  File "src/third_party/binutils/download.py", line 117, in main
    return FetchAndExtract(arch)
  File "src/third_party/binutils/download.py", line 82, in FetchAndExtract
    '-s', sha1file])
  File "/usr/lib/python2.7/subprocess.py", line 536, in check_call
    retcode = call(*popenargs, **kwargs)
  File "/usr/lib/python2.7/subprocess.py", line 523, in call
    return Popen(*popenargs, **kwargs).wait()
  File "/usr/lib/python2.7/subprocess.py", line 711, in __init__
    errread, errwrite)
  File "/usr/lib/python2.7/subprocess.py", line 1343, in _execute_child
    raise child_exception
OSError: [Errno 2] No such file or directory
Error: Command '/usr/bin/python src/third_party/binutils/download.py' returned non-zero exit status 1 in /home/shiguredo/sora-webrtc-build/webrtc
```

### ``gclient sync``: ``Check that PATH/webrtc or download_from_google_storage exist and have execution permission.``

depot_tools のコマンドのパスが検索パスに含まれていない可能性があります。

```
$ ./depot_tools/gclient sync
Syncing projects: 100% (43/43), done.
Traceback (most recent call last):
  File "./depot_tools/gclient.py", line 2681, in <module>
    sys.exit(main(sys.argv[1:]))
  File "./depot_tools/gclient.py", line 2667, in main
    return dispatcher.execute(OptionParser(), argv)
  File "/home/shiguredo/sora-webrtc-build/webrtc/depot_tools/subcommand.py", line 252, in execute
    return command(parser, args[1:])
  File "./depot_tools/gclient.py", line 2422, in CMDsync
    ret = client.RunOnDeps('update', args)
  File "./depot_tools/gclient.py", line 1512, in RunOnDeps
    self.RunHooksRecursively(self._options, pm)
  File "./depot_tools/gclient.py", line 1032, in RunHooksRecursively
    hook.run(self.root.root_dir)
  File "./depot_tools/gclient.py", line 218, in run
    cmd, cwd=cwd, always=self._verbose)
  File "/home/shiguredo/sora-webrtc-build/webrtc/depot_tools/gclient_utils.py", line 314, in CheckCallAndFilterAndHeader
    return CheckCallAndFilter(args, **kwargs)
  File "/home/shiguredo/sora-webrtc-build/webrtc/depot_tools/gclient_utils.py", line 509, in CheckCallAndFilter
    **kwargs)
  File "/home/shiguredo/sora-webrtc-build/webrtc/depot_tools/subprocess2.py", line 262, in __init__
    % (str(e), kwargs.get('cwd'), args[0]))
OSError: Execution failed with error: [Errno 2] No such file or directory.
Check that /home/shiguredo/sora-webrtc-build/webrtc or download_from_google_storage exist and have execution permission.
```
