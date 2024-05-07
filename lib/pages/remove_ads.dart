// ignore_for_file: depend_on_referenced_packages

import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:onepref/onepref.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:patikmobile/assets/style/mainColors.dart';

class RemoveAds extends StatefulWidget {
  const RemoveAds({super.key});

  @override
  State<RemoveAds> createState() => _RemoveAdsState();
}

class _RemoveAdsState extends State<RemoveAds> {
  late final List<ProductDetails> _products = <ProductDetails>[];
  IApEngine iApEngine = IApEngine();
  List<ProductId> storeProductIds = <ProductId>[
    ProductId(id: 'premium', isConsumable: false, isOneTimePurchase: true),
  ];
  void getProducts() async {
    await iApEngine.getIsAvailable().then((value) async {
      if (value) {
        await iApEngine.queryProducts(storeProductIds).then((response) async {
          setState(() {
            _products.addAll(response.productDetails);
          });
          inspect(_products);
        });
      }
    });
  }

  Future<void> listenPurchases(List<PurchaseDetails> list) async {
    for (PurchaseDetails purchase in list) {
      if (purchase.status == PurchaseStatus.restored ||
          purchase.status == PurchaseStatus.purchased) {
        if (Platform.isAndroid &&
            iApEngine
                .getProductIdsOnly(storeProductIds)
                .contains(purchase.productID)) {
          final InAppPurchaseAndroidPlatformAddition androidAddition = iApEngine
              .inAppPurchase
              .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
          inspect(androidAddition);
        }
        if (purchase.pendingCompletePurchase) {
          log('COMPLETE');

          await iApEngine.inAppPurchase.completePurchase(purchase);
        }
        //removeAds();
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    iApEngine.inAppPurchase.purchaseStream.listen(
      (event) => listenPurchases(event),
    );
    getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reklamları Kaldır'),
        backgroundColor: MainColors.backgroundColor,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 300,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async => {
                      iApEngine.handlePurchase(
                          _products[index], storeProductIds),
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: MainColors.backgroundColor),
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_products[index].description),
                          Text(_products[index].price),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
