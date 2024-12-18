import 'dart:io';

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 3001);
  print('Servidor rodando em http://localhost:3001');

  // Future.delayed(Duration(seconds: 5), () async {
  //   consumir();
  // });

  await for (HttpRequest request in server) {
    if (request.uri.path == '/video') {
      final file = File('./video.mp4');

      // Verifica se o arquivo existe
      if (await file.exists()) {
        final videoStream = file.openRead();

        // Define cabeçalhos
        request.response.headers.contentType =
            ContentType('video', 'mp4'); // Tipo de conteúdo
        // Stream de leitura conectada à resposta HTTP
        await videoStream.pipe(request.response);
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('Vídeo não encontrado');
        await request.response.close();
      }
    }
  }
}

void consumir() async {
  final url =
      Uri.parse('http://localhost:3001/video'); // URL do vídeo (servidor)
  final client = HttpClient();

  try {
    // Faz a requisição GET
    final request = await client.getUrl(url);
    final response = await request.close();

    // Verifica o status da resposta
    if (response.statusCode == HttpStatus.ok) {
      // Salva o vídeo em um arquivo local
      final file = File('downloaded_video.mp4');
      final fileStream = file.openWrite();

      // Consome a stream de resposta e escreve no arquivo
      await response.pipe(fileStream);
      await fileStream.close();

      print('Vídeo baixado com sucesso!');
    } else {
      print('Erro ao baixar o vídeo. Status: ${response.statusCode}');
    }
  } catch (e) {
    print('Erro: $e');
  } finally {
    client.close();
  }
}
