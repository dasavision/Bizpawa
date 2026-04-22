const Map<String, String> businessProductHints = {
  'Duka la Mangi & Supermarket': 'Mf. Mchele, Unga...',
  'Pharmacy & Dawa':             'Mf. Panadol, Amoxicillin...',
  'Fashion & Nguo':              'Mf. Suruali, Gauni...',
  'Chakula & Bakery':            'Mf. Chips, Mkate...',
  'Electronics & Simu':          'Mf. Earphones, Charger...',
  'Furniture & Samani':          'Mf. Sofa, Meza...',
  'Hardware & Ujenzi':           'Mf. Cement, Nondo...',
  'Jewellery & Mapambo':         'Mf. Mkufu, Pete...',
  'Microfinance & Fedha':        'Mf. Mkopo, Akiba...',
  'Spare Parts & Mashine':       'Mf. Brake Pads, Filter...',
  'Stationary & Vifaa vya Ofisi':'Mf. Kalamu, Daftari...',
  'Vinywaji & Pombe':            'Mf. Bia, Soda...',
  'Wakala & Pesa':               'Mf. Lipa Bili, Tuma Pesa...',
  'Babies & Kids':               'Mf. Diapers, Formula...',
  'Cosmetics & Beauty':          'Mf. Lipstick, Sabuni...',
  'Huduma & Services':           'Mf. Ushonaji, Ukarabati...',
};

String getProductHint(String bizType) {
  return businessProductHints[bizType] ?? 'Mf. Bidhaa yako...';
}