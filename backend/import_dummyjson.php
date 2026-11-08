<?php
declare(strict_types=1);
require_once __DIR__ . '/api/config.php';
header('Content-Type: text/html; charset=utf-8');

$url = 'https://dummyjson.com/products?limit=0';
$ch = curl_init($url);
curl_setopt_array($ch, [
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_TIMEOUT => 30,
    CURLOPT_CONNECTTIMEOUT => 10,
    CURLOPT_FOLLOWLOCATION => true,
    CURLOPT_USERAGENT => 'Flutter-CRUD-DummyJSON-Importer/1.0'
]);
$response = curl_exec($ch);
$status = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);
curl_close($ch);

if ($response === false || $status !== 200) {
    http_response_code(502);
    exit('Gagal mengambil katalog DummyJSON. Pastikan koneksi internet dan ekstensi cURL PHP aktif. ' . htmlspecialchars($error));
}
$payload = json_decode($response, true);
$products = $payload['products'] ?? [];
if (!is_array($products) || count($products) === 0) {
    http_response_code(502);
    exit('Respons DummyJSON tidak berisi daftar produk.');
}

$stmt = $pdo->prepare(
    'INSERT IGNORE INTO products (id, title, description, category, price, stock, brand, thumbnail)
     VALUES (:id, :title, :description, :category, :price, :stock, :brand, :thumbnail)'
);
$pdo->beginTransaction();
try {
    $inserted = 0;
    foreach ($products as $p) {
        $stmt->execute([
            ':id' => (int)$p['id'],
            ':title' => (string)($p['title'] ?? 'Untitled'),
            ':description' => (string)($p['description'] ?? ''),
            ':category' => (string)($p['category'] ?? 'general'),
            ':price' => (float)($p['price'] ?? 0),
            ':stock' => (int)($p['stock'] ?? 0),
            ':brand' => (string)($p['brand'] ?? ''),
            ':thumbnail' => (string)($p['thumbnail'] ?? ''),
        ]);
        $inserted += $stmt->rowCount();
    }
    $pdo->commit();
} catch (Throwable $e) {
    $pdo->rollBack();
    http_response_code(500);
    exit('Import gagal: ' . htmlspecialchars($e->getMessage()));
}
$total = (int)$pdo->query('SELECT COUNT(*) FROM products')->fetchColumn();
echo '<h2>Import katalog DummyJSON selesai</h2>';
echo '<p>Produk dari DummyJSON: ' . count($products) . '</p>';
echo '<p>Produk baru dimasukkan: ' . $inserted . '</p>';
echo '<p>Total produk di database: ' . $total . '</p>';
echo '<p>Produk yang sudah ada tidak ditimpa, sehingga perubahan CRUD Anda tetap aman.</p>';
echo '<p>Setelah berhasil, kembali ke aplikasi Flutter dan refresh daftar produk.</p>';
