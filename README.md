# radbian: Internet radio receiver on Armbian

## このプロジェクトの目的
- 直リンク系インターネットラジオとRadikoの両立ができるオーディオサーバーを作る
- Armbianを使い、各種SBCで動くシステムを作る
- Linux、各種ソフトの練習

## 使用している主なソフト（感謝）
- yt-dlp (+ yt-dlp-rajiko)
- MPD
- ffmpeg
- nginx + fcgiwrap

## インストール方法
OSバージョンは<u>Armbian 25.11.2</u>を想定。  
Armbianをインストールしたボード上で以下のコマンドを入力。まずシステムをアップデート。
```
sudo apt -y update
sudo apt -y upgrade
```
次にこのリポジトリから必要なファイルとインストールスクリプトを取得、実行。
```
git clone https://github.com/yu0john/radbian
cd ./radbian/sh-files
sudo chmod +x ./install.sh
sudo ./install.sh
sudo reboot
```

必要に応じて`/boot/firmware/config.txt`にI2S音声出力の設定を追記する。


## 使い方
`radio.local`もしくはIPアドレスでアクセス。
放送局のアイコンをクリック/タップすれば再生が開始される。

コントロールバーは左から再生/一時停止、再生終了、音量調整。
一番右の数字は現在の音量。アイコンを押すと0-100の数字が表示され、選んだ数値が反映される。
ボリュームつまみから操作した場合反映に最大10秒かかる。


画面右上に固定されている電源アイコン押下で電源モーダルが出現。シャットダウンや再起動した場合、Good Bye!が最後の画面となる。

### 放送局の追加
`/var/www/html/stationList.json`を、他の放送局を参考にしつつ追記。
放送局の画像は `/var/www/html/img/stations/`に配置。300px*300pxで.webp形式。.jpgなどは非対応。

### 物理ボタン
電源用スイッチと音量つまみは、以下のように初期設定されている。音量つまみはKY-040を想定。

スイッチ: 2秒長押しでシャットダウン。  
つまみ: 右回り+4、左周り-4。押込みでトグル。

## 各種設定
個人の環境に応じてGPIO、I2Sオーディオ、MPDの出力先などの設定が必要。ここでは標準として想定している<u>電源スイッチ、音量つまみ</u>の設定のみを紹介。
追加したいものについてはご自分でどうぞ。

`/usr/local/bin/` にある.pyファイルを書き換える。
### LED付き電源スイッチ
shutdown.pyの`BTN = 23`を対応するGPIOピン番号に書き換え。  
`elapsed_time >= 2.0`を3.0とすれば3秒長押しでシャットダウンに変更可能。  
点滅については`/etc/rc.local`および`/boot/firmware/config.txt`で設定すること。

以下、標準配線。
- ON: GPIO 23
- ON: GND
- +: GPIO 24
- -: GND

### 音量つまみ（ロータリーエンコーダ）
volume-control.pyの`CLK, DT, SW`をピンに対応させる。  
`"mpc volume +2"`を変更すれば一度の操作で変化する量が変わる。  
押込み操作は`"mpc toggle"`の以外に何でも代入してOK。

以下、標準配線。
- CLK: GPIO 5
- DT: GPIO 6
- SW: GPIO 25
- +: 3.3V
- -: GND

## 注意点
自分の **エリア外の放送を聞く方はradikoのサブスクを。** 本来エリアフリー視聴は有料コンテンツ。 [yt-dlp-rajiko](https://427738.xyz/yt-dlp-rajiko/index.ja.html)にも以下の文言あり。

>個人的なアーカイブを目的としております。商用利用はおやめください。可能であればラジコプレミアムに登録してください。

また、不具合はIssueにてお知らせください。