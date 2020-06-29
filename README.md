

### заавар

#### 2) authentication тохиргоо.

1) firebase дашбоардноос  `authentication` хэсгийг сонгоно.
2)  `setup sign in method` сонголтыг хийж `Google` гэснийг сонгоно.
4) мөн давтаад `Email/Password` хадгална.


#### 3) firebase дээр андройд апп аа бүртгүүлэх

1) андройд иконыг дарахаар `Get Started...` гэж харагдана.
2) package name дээр - `com.demo.expense`. гэж бичнэ хүсвэл дараа өөрчилж болно
3) үүний дараа repo г хуулан авч `android` хуудас дотор аваачиж терминас цонх оо нээгээд эдгээр коммандуудыг ажиллуулна:

    1) `keytool -genkey -v -alias androiddebugkey -keypass android -keystore debug.keystore -storepass android -dname "CN=Android Debug,O=Android,C=US" -keyalg RSA -keysize 2048 -validity 10000`

    2) `keytool -list -v -keystore debug.keystore -alias androiddebugkey -storepass android -keypass android`

4) хэрвээ амжилттай болсон бол үр дүнд нь харагдах SHA1 кодыг хуулан авч firebase дээрээ оруулна
5) firebase дуусмагц үүсгэгдсэн `google-services.json` файлыг татан авч `android/app` хуудас дотор хуулна


