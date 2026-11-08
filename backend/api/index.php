<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *'); // Untuk development lokal. Batasi domain saat production.
header('Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(204); exit; }
require_once __DIR__ . '/config.php';

function respond($data, int $status = 200): void {
    http_response_code($status);
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}
function input(): array {
    $raw = file_get_contents('php://input');
    $data = json_decode($raw ?: '{}', true);
    return is_array($data) ? $data : [];
}
function productById(PDO $pdo, int $id): ?array {
    $stmt = $pdo->prepare('SELECT id, title, description, category, price, stock, brand, thumbnail FROM products WHERE id = ?');
    $stmt->execute([$id]);
    $row = $stmt->fetch();
    if (!$row) return null;
    $row['id'] = (int)$row['id'];
    $row['price'] = (float)$row['price'];
    $row['stock'] = (int)$row['stock'];
    return $row;
}

$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?: '/';
$path = '/';
if (preg_match('~/api(/.*)?$~', $uri, $matches)) $path = $matches[1] ?: '/';
$path = '/' . trim($path, '/');
$method = $_SERVER['REQUEST_METHOD'];

try {
    if ($path === '/health' && $method === 'GET') {
        $productCount = (int)$pdo->query('SELECT COUNT(*) FROM products')->fetchColumn();
        respond([
            'success' => true,
            'message' => 'Backend aktif dan database terhubung',
            'databaseConnected' => true,
            'productCount' => $productCount,
        ]);
    }

    if ($path === '/categories' && $method === 'GET') {
        $rows = $pdo->query('SELECT DISTINCT category FROM products ORDER BY category')->fetchAll(PDO::FETCH_COLUMN);
        respond(['categories' => $rows]);
    }

    if ($path === '/products' && $method === 'GET') {
        $where = [];
        $params = [];
        if (isset($_GET['q']) && trim((string)$_GET['q']) !== '') {
            $where[] = '(title LIKE ? OR description LIKE ? OR brand LIKE ?)';
            $term = '%' . trim((string)$_GET['q']) . '%';
            array_push($params, $term, $term, $term);
        }
        if (isset($_GET['category']) && $_GET['category'] !== '') {
            $where[] = 'category = ?'; $params[] = (string)$_GET['category'];
        }
        $sql = 'SELECT id, title, description, category, price, stock, brand, thumbnail FROM products';
        if ($where) $sql .= ' WHERE ' . implode(' AND ', $where);
        $sortBy = ($_GET['sortBy'] ?? '') === 'price' ? 'price' : 'id';
        $order = strtolower((string)($_GET['order'] ?? 'asc')) === 'desc' ? 'DESC' : 'ASC';
        $sql .= " ORDER BY $sortBy $order";
        $limit = max(1, min(200, (int)($_GET['limit'] ?? 100)));
        $skip = max(0, (int)($_GET['skip'] ?? 0));
        $countSql = 'SELECT COUNT(*) FROM products' . ($where ? ' WHERE ' . implode(' AND ', $where) : '');
        $countStmt = $pdo->prepare($countSql); $countStmt->execute($params); $total = (int)$countStmt->fetchColumn();
        $sql .= ' LIMIT ' . $limit . ' OFFSET ' . $skip;
        $stmt = $pdo->prepare($sql); $stmt->execute($params);
        $rows = $stmt->fetchAll();
        foreach ($rows as &$row) { $row['id'] = (int)$row['id']; $row['price'] = (float)$row['price']; $row['stock'] = (int)$row['stock']; }
        respond(['products' => $rows, 'total' => $total, 'skip' => $skip, 'limit' => $limit]);
    }

    if ($path === '/products' && $method === 'POST') {
        $data = input();
        $title = trim((string)($data['title'] ?? ''));
        $category = trim((string)($data['category'] ?? 'Umum'));
        $price = $data['price'] ?? null;
        if ($title === '' || !is_numeric($price) || (float)$price < 0) respond(['success' => false, 'message' => 'Nama produk dan harga valid wajib diisi.'], 422);
        $stmt = $pdo->prepare('INSERT INTO products (title, description, category, price, stock, brand, thumbnail) VALUES (?, ?, ?, ?, ?, ?, ?)');
        $stmt->execute([$title, trim((string)($data['description'] ?? '')), $category ?: 'Umum', (float)$price, max(0, (int)($data['stock'] ?? 0)), trim((string)($data['brand'] ?? '')), trim((string)($data['thumbnail'] ?? ''))]);
        respond(['success' => true, 'message' => 'Produk berhasil ditambahkan.', 'product' => productById($pdo, (int)$pdo->lastInsertId())], 201);
    }

    if (preg_match('~^/products/(\d+)$~', $path, $matches)) {
        $id = (int)$matches[1];
        if ($method === 'GET') {
            $product = productById($pdo, $id);
            if (!$product) respond(['success' => false, 'message' => 'Produk tidak ditemukan.'], 404);
            respond($product);
        }
        if ($method === 'PUT' || $method === 'PATCH') {
            if (!productById($pdo, $id)) respond(['success' => false, 'message' => 'Produk tidak ditemukan.'], 404);
            $data = input();
            $allowed = ['title', 'description', 'category', 'price', 'stock', 'brand', 'thumbnail'];
            $sets = []; $values = [];
            foreach ($allowed as $field) {
                if (array_key_exists($field, $data)) {
                    if ($field === 'title' && trim((string)$data[$field]) === '') respond(['success' => false, 'message' => 'Nama produk tidak boleh kosong.'], 422);
                    if ($field === 'price' && (!is_numeric($data[$field]) || (float)$data[$field] < 0)) respond(['success' => false, 'message' => 'Harga tidak valid.'], 422);
                    if ($field === 'stock' && (int)$data[$field] < 0) respond(['success' => false, 'message' => 'Stok tidak valid.'], 422);
                    $sets[] = "$field = ?";
                    $values[] = $data[$field];
                }
            }
            if (!$sets) respond(['success' => false, 'message' => 'Tidak ada data yang diperbarui.'], 422);
            $values[] = $id;
            $stmt = $pdo->prepare('UPDATE products SET ' . implode(', ', $sets) . ' WHERE id = ?');
            $stmt->execute($values);
            respond(['success' => true, 'message' => 'Produk berhasil diperbarui.', 'product' => productById($pdo, $id)]);
        }
        if ($method === 'DELETE') {
            $stmt = $pdo->prepare('DELETE FROM products WHERE id = ?'); $stmt->execute([$id]);
            if ($stmt->rowCount() === 0) respond(['success' => false, 'message' => 'Produk tidak ditemukan.'], 404);
            respond(['success' => true, 'message' => 'Produk berhasil dihapus.']);
        }
    }
    respond(['success' => false, 'message' => 'Endpoint tidak ditemukan.'], 404);
} catch (Throwable $e) {
    respond(['success' => false, 'message' => 'Terjadi kesalahan pada server.'], 500);
}
