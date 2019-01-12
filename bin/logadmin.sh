#!/bin/sh

#ログローテーションされたファイルを圧縮・削除するスクリプト
#　実行前提条件
#・logname_excludelistにログが存在するディレクトリの絶対パスとログファイル名を記入すること
#・deldateには管理日数を記述（管理ののち削除）
#・compdateには管理日数を記述（管理ののち圧縮）
#・圧縮処理が必要でないならcompdateに0を記入

# ディレクトリ関連
BASEDIR="/usr/local/TOOLS/bin/logadmin"
LIBDIR="${BASEDIR}/lib"

#管理したいログファイルのディレクトリと名前を定義する
dir="${BASEDIR}/etc/loglist"

#ファイルを削除する日数を定義する
deldate=
#ファイルを圧縮する日数を定義する
#圧縮しない場合は0を入力してください
compdate=

## ログ関数用変数定義
LOGDIR="${BASEDIR}/log"
LOGFILE="${LOGDIR}/result.log_`date '+%Y-%m-%d'`"

## 共通関数読み込み
. ${LIBDIR}/Mail_Send.fnc
. ${LIBDIR}/log.fnc 

#ログファイルのディレクトリが指定されていなければエラーを出力
if [ ! -s ${dir} ]; then
    LOG ERROR "${dir}にログファイルまでの絶対パスを入力して下さい"
    Mail_Send
    exit 99
fi

#数値が入っていなければエラーを出力
if [ -z "${deldate}" ] || [ -z "${compdate}" ]; then
   LOG ERROR "deldateとcompdateに数値が入力されていません"
   Mail_Send
   exit 99
fi

#compdateに負の数値が入っていればエラーを出力
if [ 0 -gt ${compdate} ]; then
    LOG ERROR "${compdate}の値が不正です"
    Mail_Send
    exit 99
fi

#入力した数値から-1する
#findコマンドが0から計上しているためのデクリメント
deldatetrue=$(($deldate - 1))
compdatetrue=$(($compdate - 1))

while read line
    do
        #ファイル名を取得
        tgtfile=$(basename "${line}")
        #ログディレクトリを取得
        tgtdir=$(dirname "${line}")
        # ターゲットディレクトリが存在しなければ処理中止
        if [ ! ${tgtdir} = . ] && [ -d "${tgtdir}" ]; then
                # 圧縮対象の変数(compdatetrue)の値が-1以外だったら圧縮処理をする
                if [ ${compdatetrue} -ne -1 ]; then
                    #定義された日数が経過したファイルを圧縮する
                    find ${tgtdir} -name ${tgtfile} -mtime +${compdatetrue} -daystart | xargs gzip -qf
                fi
                #定義された日数が経過したファイルを削除する
                find ${tgtdir} -name ${tgtfile} -mtime +${deldatetrue} -daystart | xargs rm -f
        else
            LOG ERROR "${dir}にディレクトリが存在しません"
            Mail_Send
            exit 99
        fi
    done < ${dir}
LOG INFO "ログの圧縮・削除が完了しました"

#ログ出力先のログローテート処理
find /usr/local/TOOLS/bin/logadmin/log -name "result.log_*" -mtime +14 -daystart | xargs rm -f
