import 'dart:async';
import 'dart:io';

const _defaultListenPort = 8080;
const _targetBaseUrl = 'https://api.asynk.in';

const _hopByHopHeaders = {
  'connection',
  'keep-alive',
  'proxy-authenticate',
  'proxy-authorization',
  'te',
  'trailer',
  'transfer-encoding',
  'upgrade',
  'host',
};

Future<void> main(List<String> args) async {
  final port = _parsePort(args);
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  final client = HttpClient();

  stdout.writeln('Local API proxy listening on http://localhost:$port');
  stdout.writeln('Forwarding requests to $_targetBaseUrl');
  stdout.writeln(
    'Run Flutter web with: flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:$port',
  );

  ProcessSignal.sigint.watch().listen((_) async {
    stdout.writeln('\nStopping local API proxy...');
    client.close(force: true);
    await server.close(force: true);
    exit(0);
  });

  await for (final request in server) {
    unawaited(_handleRequest(client, request));
  }
}

int _parsePort(List<String> args) {
  if (args.isEmpty) return _defaultListenPort;

  final portArg = args.firstWhere(
    (arg) => arg.startsWith('--port='),
    orElse: () => '',
  );
  if (portArg.isEmpty) return _defaultListenPort;

  final parsed = int.tryParse(portArg.substring('--port='.length));
  if (parsed == null || parsed <= 0 || parsed > 65535) {
    stderr.writeln('Invalid port "$portArg". Using $_defaultListenPort.');
    return _defaultListenPort;
  }
  return parsed;
}

Future<void> _handleRequest(HttpClient client, HttpRequest request) async {
  _addCorsHeaders(request.response);

  if (request.method.toUpperCase() == 'OPTIONS') {
    request.response.statusCode = HttpStatus.noContent;
    await request.response.close();
    return;
  }

  var responseCommitted = false;

  try {
    final target = Uri.parse(
      _targetBaseUrl,
    ).replace(path: request.uri.path, query: request.uri.query);
    final upstream = await client.openUrl(request.method, target);

    request.headers.forEach((name, values) {
      if (_hopByHopHeaders.contains(name.toLowerCase())) return;
      upstream.headers.set(name, values);
    });

    await upstream.addStream(request);
    final upstreamResponse = await upstream.close();

    request.response.statusCode = upstreamResponse.statusCode;
    upstreamResponse.headers.forEach((name, values) {
      if (_hopByHopHeaders.contains(name.toLowerCase())) return;
      request.response.headers.set(name, values);
    });
    _addCorsHeaders(request.response);

    responseCommitted = true;
    await upstreamResponse.pipe(request.response);
  } catch (error, stackTrace) {
    stderr.writeln('Proxy request failed: $error');
    stderr.writeln(stackTrace);

    if (!responseCommitted) {
      request.response.statusCode = HttpStatus.badGateway;
      request.response.headers.contentType = ContentType.json;
      request.response.write('{"detail":"Local API proxy failed."}');
      await request.response.close();
    }
  }
}

void _addCorsHeaders(HttpResponse response) {
  response.headers
    ..set(HttpHeaders.accessControlAllowOriginHeader, '*')
    ..set(
      HttpHeaders.accessControlAllowMethodsHeader,
      'GET,POST,PUT,PATCH,DELETE,OPTIONS',
    )
    ..set(
      HttpHeaders.accessControlAllowHeadersHeader,
      'authorization,content-type,accept',
    );
}
