<?php
// Autoriser uniquement JSON
header("Content-Type: application/json");

// Autoriser uniquement les requêtes POST
if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    echo json_encode(["success" => false, "message" => "Méthode non autorisée"]);
    exit;
}

// Récupérer le JSON envoyé par Flutter
$input = json_decode(file_get_contents("php://input"), true);

if (!$input) {
    echo json_encode(["success" => false, "message" => "Aucune donnée reçue"]);
    exit;
}

// Sécurisation basique
$ets_name = trim(htmlspecialchars($input["ets_name"] ?? ""));
$email = trim(filter_var($input["email"] ?? "", FILTER_SANITIZE_EMAIL));
$phone_number = trim(htmlspecialchars($input["phone_number"] ?? ""));

// Vérification
if (empty($ets_name) || empty($email) || empty($phone_number)) {
    echo json_encode(["success" => false, "message" => "Champs manquants"]);
    exit;
}
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode(["success" => false, "message" => "Email invalide"]);
    exit;
}

// Connexion MySQL (⚠️ adapte avec tes infos)
$host = "sugubougou.com";
$dbname = "sugubougou_transferly";
$username = "sugubougou";
$password = "123lovelife";

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    // Préparer la requête (évite l’injection SQL)
    $stmt = $pdo->prepare("INSERT INTO entreprises (ets_name, email, phone_number) VALUES (:ets_name, :email, :phone_number)");
    $stmt->execute([
        ":ets_name" => $ets_name,
        ":email" => $email,
        ":phone_number" => $phone_number
    ]);

    // Réponse JSON
    echo json_encode([
        "success" => true,
        "message" => "Infos enregistrées avec succès ✅",
        "data" => [
            "ets_name" => $ets_name,
            "email" => $email,
            "phone_number" => $phone_number
        ]
    ]);

} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Erreur serveur : " . $e->getMessage()
    ]);
}
