import 'package:flutter/material.dart';
import 'package:cd/application.dart';
import 'package:cd/generated/i18n.dart';
import 'package:cd/main.dart';
import 'package:cd/utils/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info/package_info.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _language;
  String _version;
  String _packageName;
  bool _isDarkTheme;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            S.of(context).settings,
            style: Theme.of(context).textTheme.headline.copyWith(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Container(
          color: Theme.of(context).backgroundColor,
          child: ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                child: Text(
                  S.of(context).common,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                ),
              ),
              ListTile(
                dense: true,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        title: Text(S.of(context).select_language),
                        contentPadding: EdgeInsets.all(10.0),
                        children: <Widget>[
                          RadioListTile(
                            value: "tr",
                            groupValue: _language,
                            onChanged: (val) {
                              SharedPreferencesHelper.setLanguage(val);
                              setState(() => _language = val);
                              application.onLocaleChanged(val);
                              MyApp.setLanguage(context, val);
                              Navigator.of(context).pop();
                            },
                            title: Text(
                              S.of(context).turkish,
                              style: Theme.of(context).textTheme.subtitle,
                            ),
                            activeColor: Theme.of(context).primaryColor,
                            dense: true,
                          ),
                          RadioListTile(
                            value: "en",
                            groupValue: _language,
                            onChanged: (val) {
                              SharedPreferencesHelper.setLanguage(val);
                              setState(() => _language = val);
                              application.onLocaleChanged(val);
                              MyApp.setLanguage(context, val);
                              Navigator.of(context).pop();
                            },
                            title: Text(
                              S.of(context).english,
                              style: Theme.of(context).textTheme.subtitle,
                            ),
                            activeColor: Theme.of(context).primaryColor,
                            dense: true,
                          ),
                          RadioListTile(
                            value: "de",
                            groupValue: _language,
                            onChanged: (val) {
                              SharedPreferencesHelper.setLanguage(val);
                              setState(() => _language = val);
                              application.onLocaleChanged(val);
                              MyApp.setLanguage(context, val);
                              Navigator.of(context).pop();
                            },
                            title: Text(
                              S.of(context).german,
                              style: Theme.of(context).textTheme.subtitle,
                            ),
                            activeColor: Theme.of(context).primaryColor,
                            dense: true,
                          ),
                          RadioListTile(
                            value: "fr",
                            groupValue: _language,
                            onChanged: (val) {
                              SharedPreferencesHelper.setLanguage(val);
                              setState(() => _language = val);
                              application.onLocaleChanged(val);
                              MyApp.setLanguage(context, val);
                              Navigator.of(context).pop();
                            },
                            title: Text(
                              S.of(context).french,
                              style: Theme.of(context).textTheme.subtitle,
                            ),
                            activeColor: Theme.of(context).primaryColor,
                            dense: true,
                          ),
                        ],
                      );
                    },
                  );
                },
                leading: Icon(
                  Icons.translate,
                  size: 35.0,
                  color: Theme.of(context).accentIconTheme.color,
                ),
                title: Text(
                  S.of(context).language,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(_language?.toUpperCase() ?? ""),
              ),
              ListTile(
                dense: true,
                onTap: () => {},
                leading: Icon(
                  Icons.color_lens,
                  size: 35.0,
                  color: Theme.of(context).accentIconTheme.color,
                ),
                title: Text(
                  S.of(context).dark_theme,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Switch(
                  value: _isDarkTheme,
                  onChanged: (val) {
                    SharedPreferencesHelper.setDarkTheme(val);
                    setState(() => _isDarkTheme = val);
                    MyApp.setTheme(context, val);
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                child: Text(
                  S.of(context).about,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                ),
              ),
              ListTile(
                dense: true,
                onTap: () => {},
                leading: Icon(
                  Icons.info,
                  size: 35.0,
                  color: Theme.of(context).accentIconTheme.color,
                ),
                title: Text(
                  S.of(context).build_number,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(_version ?? ""),
              ),
              Divider(height: 0),
              ListTile(
                dense: true,
                onTap: () => Share.share("https://play.google.com/store/apps/details?id=$_packageName"),
                leading: Icon(
                  Icons.mobile_screen_share,
                  size: 35.0,
                  color: Theme.of(context).accentIconTheme.color,
                ),
                title: Text(
                  S.of(context).share,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Divider(height: 0),
              ListTile(
                dense: true,
                onTap: () => _launchURL("mailto:${DotEnv().env['CONTACT_EMAIL']}?subject=${S.of(context).mail_subject}"),
                leading: Icon(
                  Icons.feedback,
                  size: 35.0,
                  color: Theme.of(context).accentIconTheme.color,
                ),
                title: Text(
                  S.of(context).feedback,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Divider(height: 0),
              ListTile(
                dense: true,
                onTap: () => _launchURL("https://play.google.com/store/apps/details?id=$_packageName"),
                leading: Icon(
                  Icons.rate_review,
                  size: 35.0,
                  color: Theme.of(context).accentIconTheme.color,
                ),
                title: Text(
                  S.of(context).google_play_rating,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ));
  }

  _loadData() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    _language = await SharedPreferencesHelper.getLanguage();
    _isDarkTheme = await SharedPreferencesHelper.isDarkTheme();
    _version = packageInfo.version;
    _packageName = packageInfo.packageName;
    setState(() {});
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
