#login='perm'
#password='7753099661'

login='node1037700013020195'
password='9865614351'

CONT_pref="\\\\.\\HDIMAGE\\"
CONT="Masterchain-"

CACRED="$login:$password"
CAURL="https://${CACRED}@testca2012.cryptopro.ru/ui/"

CATOKEN=`echo $CAURL | sed -E 's#[^:]*://([^:]*):.*#\1#'`
CAPASSWORD=`echo $CAURL | sed -E 's#[^:]*://[^:]*:([^@]*)@.*#\1#'`
CAURL=`echo $CAURL | sed -E 's#([^:]*://)[^@]*@(.*)$#\1\2#'`

get_line() {
    head -n $1 | tail -n 1
}

HN=`hostname`
RDN='E=KartelAG@cbr.ru,C=RU,CN='$HN
num=0
certs=( $certs )

RQID=`mktemp`
RES=`mktemp`
curCont="\\\\.\\HDIMAGE\\server"
/opt/cprocsp/bin/amd64/cryptcp -creatcert -rdn $RDN \
         -provtype 80 -both -ku -hashalg '1.2.643.7.1.1.2.2' \
         -CPCA20 $CAURL -token $CATOKEN -tpassword $CAPASSWORD \
         -tmpl 'tls-mch-net-srv' -FileID $RQID -cont "${curCont}" -pin "" 

while : ; do
    /opt/cprocsp/bin/amd64/cryptcp -pendcert -FileID $RQID -cont "${curCont}" \
        -CPCA20 $CAURL -token $CATOKEN -tpassword $CAPASSWORD -pin ""  > $RES 2>&1
    cat $RES
    egrep -q "installed|установлен" $RES && break
    echo "Waiting for certificate request $(<$RQID) to be processed"
    sleep 1
done


RQID=`mktemp`
RES=`mktemp`
curCont="\\\\.\\HDIMAGE\\client"
/opt/cprocsp/bin/amd64/cryptcp -creatcert -rdn $RDN \
         -provtype 80 -both -ku -hashalg '1.2.643.7.1.1.2.2' \
         -CPCA20 $CAURL -token $CATOKEN -tpassword $CAPASSWORD \
         -tmpl "tls-mch-net-clt" -FileID $RQID -cont "${curCont}" -pin "" 

while : ; do
    /opt/cprocsp/bin/amd64/cryptcp -pendcert -FileID $RQID -cont "${curCont}" \
        -CPCA20 $CAURL -token $CATOKEN -tpassword $CAPASSWORD -pin ""  > $RES 2>&1
    cat $RES
    egrep -q "installed|установлен" $RES && break
    echo "Waiting for certificate request $(<$RQID) to be processed"
    sleep 1
done



echo "Все сертификаты установлены"
/opt/cprocsp/bin/amd64/certmgr -export -dest ./server.cer -cont '\\.\HDIMAGE\server'
/opt/cprocsp/bin/amd64/certmgr -export -dest ./client.cer -cont '\\.\HDIMAGE\client'
