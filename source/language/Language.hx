package language;

import language.locales.*;

class Language
{
    public static var member:Array<String> = 
        [
            EN.langTran.get('LangName'),
            ZH.langTran.get('LangName'),
            ENbutold.langTran.get('LangName')
        ];

    static public function getStr(name:String):String
    {
        switch(ClientPrefs.data.language)
        {
            case 'English':
                return  EN.langTran.get(name);
            case '简体中文':
                return ZH.langTran.get(name);
            case 'English-Old':
                return ENold.langTran.get(name);
        }
        return  EN.langTran.get(name);
    }    
}
