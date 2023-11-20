import 'dart:io';

Future<String> readFile(String filePath) async {
  return await File(filePath).readAsString();
}

Future<String> getErc20Abi() async {
  return await readFile('lib/assets/abi/erc20.json');
}

Future<String> getErc721Abi() async {
  return await readFile('lib/assets/abi/erc721.json');
}

Future<String> getErc1155Abi() async {
  return await readFile('lib/assets/abi/erc1155.json');
}
