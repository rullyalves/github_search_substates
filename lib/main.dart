import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:github_search/blocs/SearchBloc.dart';
import 'package:github_search/blocs/SearchState.dart';
import 'package:github_search/details/DetailsWidget.dart';
import 'package:github_search/models/SearchItem.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SearchBloc _searchBloc;

  @override
  void initState() {
    _searchBloc = new SearchBloc();
    super.initState();
  }

  @override
  void dispose() {
    _searchBloc?.dispose();
    super.dispose();
  }

  Widget _textField() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                onChanged: _searchBloc.searchEvent.add,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Digite o nome do repositório",
                    labelText: "Pesquisa"),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: StreamBuilder<Object>(
                    stream: _searchBloc.message,
                    builder: (context, snapshot) {
                      return snapshot.hasData
                          ? Text("resultados para ${snapshot.data}")
                          : Container();
                    }),
              ),
            ],
          ),
        ));
  }

  Widget _items(SearchItem item) {
    print("teste");

    return ListTile(
      leading: Hero(
        tag: item.url,
        child: CircleAvatar(
          backgroundImage: NetworkImage(item?.avatarUrl ??
              "https://d2v9y0dukr6mq2.cloudfront.net/video/thumbnail/VCHXZQKsxil3lhgr4/animation-loading-circle-icon-on-white-background-with-alpha-channel-4k-video_sjujffkcde_thumbnail-full01.png"),
        ),
      ),
      title: Text(item?.fullName ?? "title"),
      subtitle: Text(item?.url ?? "url"),
      onTap: () => Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => DetailsWidget(
                    item: item,
                  ))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Github Search"),
      ),
      body: ListView(
        children: <Widget>[
          _textField(),
          StreamBuilder<SearchState>(
            initialData: SearchNoTerm(),
            stream: _searchBloc.apiResultFlux,
            builder:
                (BuildContext context, AsyncSnapshot<SearchState> snapshot) {
              return _buildItems(snapshot);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItems(AsyncSnapshot<SearchState> snapshot) {
    if (snapshot.data is SearchNoTerm) {
      return Center(
        child: Column(
          children: <Widget>[
            Icon(Icons.search, size: 50),
            Text("Pesquise por algo"),
          ],
        ),
      );
    } else if (snapshot.data is SearchLoading) {
      return Center(
        child: Container(
            width: 50, height: 50, child: CircularProgressIndicator()),
      );
    } else if (snapshot.data is SearchSuccess) {
      SearchSuccess success = snapshot.data;
      return ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: success.results.length,
        itemBuilder: (BuildContext context, int index) {
          SearchItem item = success.results[index];
          return _items(item);
        },
      );
    } else if (snapshot.data is SearchError) {
      return Center(
        child: Column(
          children: <Widget>[
            Icon(
              Icons.error,
              size: 50,
            ),
            Text("algo deu errado"),
          ],
        ),
      );
    } else if (snapshot.data is SearchEmpty) {
      return Center(
        child: Column(
          children: <Widget>[
            Icon(
              Icons.info_outline,
              size: 50,
            ),
            Text("resultado vazio"),
          ],
        ),
      );
    }
  }
}
