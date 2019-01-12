#==============================================
# sendmail関数
#==============================================
# 
## メール送信関数用変数定義
from1=""
to1="vagrant@example.com"
cc1=""
subject_err1="$(basename $0 .sh) ${HNAME} failed"
contents_err1="$0の実行中にエラーが発生しました\n詳細はログファイル${LOGFILE}を確認してください"

function Mail_Send() {
    from="$from1"
    to="$to1"
    cc="$cc1"
    subject="$subject_err1"
    contents="$contents_err1"
    inputEncoding="utf-8"
    outputEncoding="iso-2022-jp"
    subjectHead="=?$outputEncoding?B?"
    subjectBody="`echo "$subject" | iconv -f $inputEncoding -t $outputEncoding | base64 | tr -d '\n'`"
    subjectTail="?="
    fullSubject="${subjectHead}${subjectBody}${subjectTail}"
    mail_ex_Headers='MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
'
    mailHeaders="Subject: $fullSubject
From: $from
To: $to
"
    mailContents="`echo -e $contents | iconv -f $inputEncoding -t $outputEncoding`"
    echo "${mail_ex_Headers}${mailHeaders}${mailContents}" | sendmail -t -f ${from}
    return $?
}
