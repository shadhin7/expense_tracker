'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "f84e046777f0667b31af9fe10ece10ab",
".git/config": "920a11de313bfb8d93d81f4a3a5b71b6",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/HEAD": "4cf2d64e44205fe628ddd534e1151b58",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "e2df82c10dec1f0ee43cf4608323f8ba",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "5bc7837055b2451654043f857b70d6b2",
".git/logs/refs/heads/master": "5bc7837055b2451654043f857b70d6b2",
".git/objects/02/1d4f3579879a4ac147edbbd8ac2d91e2bc7323": "9e9721befbee4797263ad5370cd904ff",
".git/objects/08/58bf7ce41c97eb5c46c46e7948ec9b824fd234": "11a238db779f03afccf0ff60550f65f7",
".git/objects/0d/655c46f32db69db723f39306ee92a34749705e": "1e66b4f92d11968d38b8f94eb2ede5db",
".git/objects/15/b8362cb8e18e8834f2ceb867937e2c2688ae66": "360595d38190fed48138913a99f75293",
".git/objects/20/3a3ff5cc524ede7e585dff54454bd63a1b0f36": "4b23a88a964550066839c18c1b5c461e",
".git/objects/21/f7d63c49a7fbc57fb572545f199f72ef33c81c": "b55eebe82ad51ec7f6eeaf8365a68064",
".git/objects/22/95ea507abc7d3bc711fdfce9879cefae73e9b9": "83a53874897c8a05390555cc3cf40e77",
".git/objects/29/f22f56f0c9903bf90b2a78ef505b36d89a9725": "e85914d97d264694217ae7558d414e81",
".git/objects/35/8f3453894c219a93882eafc81f2d6ac8a64738": "50e814c48bcfdbba9f6d92e6c0a54e2c",
".git/objects/37/855a658bc8c4d4f236ac60cd1d486dcb864975": "e165c3d9d5067d2fdc8be613b6b9fd4e",
".git/objects/3d/4e3c4024284cb4445d29a645866fd246df81e0": "f173320f5fc9e707385a6a534e53d087",
".git/objects/40/6850f3008b19649362a33239c11285f9777bab": "99f42708a66b26c8a338719c00ab0b04",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/46/8bc9e812d0c9ff5e22c2d46b10fdbc765430fe": "a8d47dae819ef692e331406ab79a64cd",
".git/objects/48/2cc30d5ce0baf9770bc98a63dc7f7eafea1c25": "ebc3896ab247bd794568ddb2c0305ad5",
".git/objects/4a/4e7dadf7821ca2aa59e699b33a72d4008029d0": "1bfa74e559cf83cac32c62aa1cef4a23",
".git/objects/4b/c34eb72323ba35699fda450d4a77029097b833": "31916304db8da438fbfaa998e0868f98",
".git/objects/4b/f3354f7c159bef42678c2b84816ee2b8b56a1b": "d680b6671ef64295ad0997c85cc8bb62",
".git/objects/4d/bf9da7bcce5387354fe394985b98ebae39df43": "534c022f4a0845274cbd61ff6c9c9c33",
".git/objects/4f/ef66116e49d99dc2f6a5b76a96cea21ac2cdc4": "d5d1579217d464bcde88f146f89bdc8d",
".git/objects/4f/fbe6ec4693664cb4ff395edf3d949bd4607391": "2beb9ca6c799e0ff64e0ad79f9e55e69",
".git/objects/52/beb7fadd2e33678f24ab7ce75e5ca5225dd630": "653a8256fb6ac2db42abdee26bb81cf9",
".git/objects/54/b497ea54fd9666170fa5189c05a9c1aa2e0e1c": "e0d8dbcb44a51b52a983649a196d6181",
".git/objects/5e/49326dc916b5b31a08019ce195c84ba70fbaa8": "8153524072a76cd48ad743af597b4867",
".git/objects/5f/4ea945561cc8314c569b588369d92cf9b9c7f2": "c621de5b969355c9be3dc82ba4541ca6",
".git/objects/68/7a6ddecab8326f8dae3d76b46e0f82ef774f0f": "3e8a8a8c1c8579746de269a6148c3478",
".git/objects/69/0dfede9b5c62f5b994f17b2d2087d2dadeeaee": "577855911bac300de9498bea03653c26",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "85896cd5fba127825eb58df13dfac82b",
".git/objects/70/5e0ae2c3a39d9ca3f89906949751a68d609eb5": "dec33af66496d440146cce4ce4d91a92",
".git/objects/72/1c54d77f4df9cede624a9d556ccdd515fdc344": "fd68f36a48bace3cc178a737801c1acf",
".git/objects/79/fcb931529d601fab71dd1d3b360e9b5713f6ee": "1792bbc769addf584ac071a52b576343",
".git/objects/7a/317bdde3cff071fe52df1f36e03450c34a830d": "bc30502110ba7634da569e68b9484aac",
".git/objects/7a/6c1911dddaea52e2dbffc15e45e428ec9a9915": "f1dee6885dc6f71f357a8e825bda0286",
".git/objects/7d/b185c25330f5bfeeee45b04077229e9ac53f4b": "b10dca5a092f7a1848b81a724bd03378",
".git/objects/7d/febda82080726d5ccce0f60c88c37ec823c0e1": "870e2997c72a8c730f50d77e8b466db2",
".git/objects/83/5bf99eb64f7448032e9f95ecfa4cee1ca37032": "6df550f5f6291b0491c996dd9e36f915",
".git/objects/8a/24d3fe42f40742fd389707a43cc129c04f0e8c": "5deaa66bbcb473b288b61fc337fea171",
".git/objects/8e/63274f5351f5a187d7837e0f4e2767338a9c40": "1ead488e04e8b33f834b21a81ed117fb",
".git/objects/8f/5afd40d7e365e6afbd5a5ef18692ebece5756c": "a02491823141dfbc8537eee3cf7f446d",
".git/objects/94/bb795ca1198f8404fe503207c503fa4bc08bbb": "16bc161a2ad8b734616ab304bb8cc052",
".git/objects/98/0d49437042d93ffa850a60d02cef584a35a85c": "8e18e4c1b6c83800103ff097cc222444",
".git/objects/9b/3ef5f169177a64f91eafe11e52b58c60db3df2": "91d370e4f73d42e0a622f3e44af9e7b1",
".git/objects/9e/3b4630b3b8461ff43c272714e00bb47942263e": "accf36d08c0545fa02199021e5902d52",
".git/objects/9f/cb9312b932fbbe66ade38553e150b437ae4480": "9ce2a629824d25b5508af6d88187d9ef",
".git/objects/b0/320f91b56b3895236f6c237dd92896ca258c83": "b207f3428c0bb4f5b9cab0e6f74d6aad",
".git/objects/b1/54ad8783e0f9b6975deffd587c9b678e77bbcc": "9b563accffd71a6a53c5520911d0cc7c",
".git/objects/b4/5f8959b343666a137e3121292b3d406397a0ec": "300fd561bcc978fa779e255ecc7a52e4",
".git/objects/b5/1539aa24b84d081b43da554321dbbc235d6bab": "9dc03a4f25d1af65576aef0581050b63",
".git/objects/b6/b8806f5f9d33389d53c2868e6ea1aca7445229": "b14016efdbcda10804235f3a45562bbf",
".git/objects/b9/bdd83d5c982911980b63b5cc2e76bce4603a40": "0db02e6a954c3c093edfc919066e821c",
".git/objects/c4/016f7d68c0d70816a0c784867168ffa8f419e1": "fdf8b8a8484741e7a3a558ed9d22f21d",
".git/objects/c8/b09797029957221129bed5b856d6adc36b7004": "01197a4800e92ed02f65349eb3d8f6d6",
".git/objects/ca/3bba02c77c467ef18cffe2d4c857e003ad6d5d": "316e3d817e75cf7b1fd9b0226c088a43",
".git/objects/cb/40648838e286f1822ccf6e7a66c1e03ab7fdd9": "93f7db2fc9ff562776868b30aee05303",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/d7/52771174b861044f1ecf0fcbfd55e0e77cfee1": "1324ea03a595d1196f8e44d9dbb92834",
".git/objects/d7/7cfefdbe249b8bf90ce8244ed8fc1732fe8f73": "9c0876641083076714600718b0dab097",
".git/objects/db/9c68dc9b3e7d0cfe672f61d14170ed19235224": "f04face458d809f2da57b2d2e5a6601c",
".git/objects/db/c26718134d1af83b664b90cbdb36ac36fe4139": "eaccb7496448d2bcb37ba1126aa6e808",
".git/objects/e3/e9ee754c75ae07cc3d19f9b8c1e656cc4946a1": "14066365125dcce5aec8eb1454f0d127",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "2eed33506ed70a5848a0b06f5b754f2c",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/ec/64153624aecda0e84d7e2bb14ca0f2c56258a3": "50dbc87f4b05191625012422d573c758",
".git/objects/ed/b55d4deb8363b6afa65df71d1f9fd8c7787f22": "886ebb77561ff26a755e09883903891d",
".git/objects/ef/3d2af8b0338fe9d59e1b0a8f730165d48c949a": "ec690ee207be08320f353c11b01478cc",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "e68f5265f0bb82d792ff536dcb99d803",
".git/objects/fb/5d2e63d2394bcb4bd4f249e082a9cba9017d8a": "709a722eaf3b6966671d96fa584acd13",
".git/objects/fe/0cfc843737fed2791ac6103889c63bbdc8c672": "cc75a28cae9e1e4fb743f35f37b694d1",
".git/objects/fe/3b987e61ed346808d9aa023ce3073530ad7426": "dc7db10bf25046b27091222383ede515",
".git/refs/heads/master": "7fe6ee1ae598efa29d5847ff3c62bdb0",
"assets/AssetManifest.bin": "6a7161bb1ac58972459f2e042bae3960",
"assets/AssetManifest.bin.json": "c65fd6e417b3435e7eebc26e79de98b2",
"assets/AssetManifest.json": "6ccaf96ed4a0de2d794c5d63477824ce",
"assets/assets/icons/bag.png": "d7d920962457893265de13f5f26d2491",
"assets/assets/icons/basket.png": "24d98bd62b14ed41eb633e5bb5ec57b9",
"assets/assets/icons/cart-minus.png": "b18bdb7720a6df4990f44cd1e16ed8f0",
"assets/assets/icons/expenses.png": "3c09b62f3b1a0810d9a0fa03080cfade",
"assets/assets/icons/Freelance.png": "fbb5fdb8c9246f29dac24d32bef5fa68",
"assets/assets/icons/income.png": "9a46c6a743394ceb965814936d2b7692",
"assets/assets/icons/meal.png": "98c6b145cd4d2b1020c3bc2a3dda7612",
"assets/assets/icons/money-transfer.png": "5a0ea90fbaf53871672ad006ed99a7d0",
"assets/assets/icons/rent.png": "7192a84a60eb6cbdc044071cc2a84b93",
"assets/assets/icons/salary.png": "d3c301721a0b5da96778856c727ae7c5",
"assets/assets/icons/vehicles.png": "9c5c30ab399d4b974fd4b05fb1fb40bc",
"assets/assets/icons/wages.png": "e57078d4a67ede8a7b137d3296c5de23",
"assets/assets/images/ex.png": "6ab79e498eedc3e83285703ec6ea44b9",
"assets/assets/images/Icon.png": "185609418d472bad06e2bb03056dcd59",
"assets/assets/images/inc.png": "bac74c0e5fd0c3634ac90e6dceaa7110",
"assets/assets/images/Newicon.png": "08776d62a0332c8b5161ceda55feae47",
"assets/assets/images/Splash.png": "e6c1fa7d61fda4c16e2952988861b542",
"assets/assets/images/TRACK_IT.png": "2d1298d40c3fed52fc8b1bd0a59e14b6",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "40388cf70747ee25971b00ebc464e347",
"assets/NOTICES": "937b444d92ad324ea60298d8c4f325eb",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"favicon.png": "584afddf35aea1261241faef52b640dd",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "ae24477dbff9ff353a8ca0c1ab44a619",
"icons/Icon-192.png": "3e4548c2596f22cd67d33c3b2638371d",
"icons/Icon-512.png": "9f1c3ba4a74089e6e2cce6e306befa23",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "d91f01deeb55f1d7b1b3f08898bfb3a4",
"/": "d91f01deeb55f1d7b1b3f08898bfb3a4",
"main.dart.js": "c64fbfa11b134114b41348da49977c98",
"manifest.json": "4ef7f6ebb915dd4123d4d7e9647b6c71",
"splash/img/dark-1x.png": "d6e1669dedecdb30ac033a0d777428e2",
"splash/img/dark-2x.png": "d4fb384b92f63574e397ab6f6c8a6749",
"splash/img/dark-3x.png": "f0ab30b577dbc206c7e4dd922564d47c",
"splash/img/dark-4x.png": "243424ff2f93624ca64d4d884f975da7",
"splash/img/light-1x.png": "d6e1669dedecdb30ac033a0d777428e2",
"splash/img/light-2x.png": "d4fb384b92f63574e397ab6f6c8a6749",
"splash/img/light-3x.png": "f0ab30b577dbc206c7e4dd922564d47c",
"splash/img/light-4x.png": "243424ff2f93624ca64d4d884f975da7",
"version.json": "f94d75a24231d4b95dc6dfd5ba454930"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
