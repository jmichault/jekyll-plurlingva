#!/usr/bin/env sh
#################################################################
# skripto por aŭtomate traduki frazojn sen traduko en po-dosieron
#################################################################

src=eo

#FIC=locale/en/LC_MESSAGES/motioneye.po
FIC=$1
BASEDIR=`dirname $0`
dst=`grep "^\"Language: .*\\n\"$" $FIC|sed "s/^\"Language: //;s/.n\"$//"`

cat $FIC|awk -v src=$src -v dst=$dst '{
  if ( CONTMSG==1 && substr($1,1,1) != "\"")
  {
    CONTMSG=0;
  }
  if ($1 == "msgid")
  {
    MSGID=substr($0,7);
    MSGWRAP=0;
    if(MSGID=="\"\"")
    {
      CONTMSG=1;
      MSGWRAP=1;
    }
  }
  else if ( CONTMSG==1 && substr($1,1,1) == "\"")
  {
    MSGID=MSGID "\n" $0;
  }
  else if ($1 == "msgstr")
  {
    if($2 != "\"\"" || MSGID == "\"\"")
    {
      print ("msgid " MSGID);
      print $0;
    }
    else
    {
      if(MATTER == "lang")
      {
        print ("msgid " MSGID);
        printf("msgstr \"" dst "\"\n");
      }
      else if(MATTER == "layout")
      {
        print ("msgid " MSGID);
        print ("msgstr " MSGID);
      }
      else if(MATTER == "lang-ref")
      {
        print ("msgid " MSGID);
        print ("msgstr " MSGID);
      }
      else
      {
        print ("#, fuzzy");
        print ("msgid " MSGID);
        printf("msgstr \"");
        LEN=length(MSGID);
        FIN="";
        if( index(MSGID,"  \\n") == LEN-4)
        {
	  MSGID=substr(MSGID,1,LEN-5)"\"";
          FIN="  \\n";
        }
        else if( index(MSGID,"\\n") == LEN-2)
        {
	  MSGID=substr(MSGID,1,LEN-3) "\"";
          FIN="\\n";
        }
        if(MSGWRAP==1)
        {
          split(MSGID,MSGS,"\n",SEPS);
	  printf("\"\n");
          for (x=2 ; x<=length(MSGS) ; x++)
          {
	    printf("\"");
            MSG=system("../_scripts/traduko.sh " src " " dst " " MSGS[ x ] )
	    printf("\"\n");
            #print( SEPS[ x ] );
            if(FIN != "") printf( "\"" FIN "\"\n");
          }
        }
        else
        {
          MSG=system("../_scripts/traduko.sh " src " " dst " " MSGID )
          printf( FIN "\"\n");
        }
      }
      MATTER="";
    }
  }
  else if (substr($0,1,28) == "#. type: YAML Front Matter: ")
  {
    MATTER=substr($0,29);
    print $0;
  }
  else
  {
    print $0;
  }
}' >$FIC.$$
mv $FIC $FIC.old
mv $FIC.$$ $FIC