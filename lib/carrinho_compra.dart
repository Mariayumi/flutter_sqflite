import 'package:flutter/material.dart';
import 'package:flutter_sqlite/listagem_produtos.dart';
import 'package:flutter_sqlite/login.dart';
import 'package:flutter_sqlite/model/produto.dart';


class CarrinhoCompra extends StatefulWidget {
  final List<int> prodSelecionados;
  final List<Produto> produtos;

  const CarrinhoCompra({Key? key, required this.produtos, required this.prodSelecionados}) : super(key: key);

  @override
  CarrinhoCompraState createState() => CarrinhoCompraState();
}

class CarrinhoCompraState extends State<CarrinhoCompra> {
  final List<Produto> _produtos = [];
  List<int> quantidadesList = [];
  bool desconto = false;
  Color textColor = Colors.black;
  Color textColorWarning = Colors.grey;
  Color borderColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    setState(() {
      _produtos.addAll(widget.produtos);
      quantidadesList = List<int>.filled(widget.produtos.length, 1);
    });
  }

  int calcularQuantidadeTotal() {
    int quantidadeTotal = 0;
    for (int quantidade in quantidadesList) {
      quantidadeTotal += quantidade;
    }
    if (quantidadeTotal >= 10) {
      setState(() {
        desconto = true;
      });
    }
    return quantidadeTotal;
  }

List<double> calcularValorTotal() {
  double valorTotal = 0;
  for (int i = 0; i < _produtos.length; i++) {    
    var price = _produtos[i].price;
    print(price);
 valorTotal += (price is String
    ? double.tryParse(price) ?? 0 
    : price) *
    quantidadesList[i];
  }
  if (desconto) {
    double valorComDesconto = valorTotal - (valorTotal * 0.05);
    double valorDoDesconto = valorTotal * 0.05;
    return [valorComDesconto, valorDoDesconto];
  }
  return [valorTotal, 0.0];
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ListagemProdutos(selecionados: widget.prodSelecionados)),
            );
            ;
          },
        ),
        title: const Text("Carrinho"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 50.0),
            Text('Quantidade de produtos ${calcularQuantidadeTotal()}',
                style: TextStyle(fontSize: 25.0, color: Colors.pinkAccent)),
            Text('Valor total: ${calcularValorTotal()[0]}',
                style: TextStyle(fontSize: 25.0, color: Colors.pinkAccent)),
            Text(desconto ? 'Desconto: 5%' : 'Desconto: 0%'),
            desconto ? Text("Desconto: ${calcularValorTotal()[1]}") : Text(""),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1.0),
                ),
                child: ListView.builder(
                  itemCount: _produtos.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = _produtos[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                  Text('${item.title}',
                                      style: const TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8.0),
                                  Text('Cod#${item.id}',
                                      style: const TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      const Text('Preço:',
                                      style: const TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold)
                                      ),
                                      Text(item.price.toString(),
                                      style: const TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                              const SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text('Quantidade'),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setState(() {
                                          quantidadesList[index] =
                                              int.parse(value);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Login(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(180, 50),
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Cancelar Pedido', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            backgroundColor: Color(Colors.green.value),
                            content: Text('Pedido Enviado Com Sucesso')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(180, 50),
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Comprar', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}