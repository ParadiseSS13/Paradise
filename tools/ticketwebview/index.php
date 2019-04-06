<?php
// PHP page for viewing all DB tickets. Shows 50 per page
// Author: AffectedArc07
$servername = "localhost"; // Hostname of the database server (default localhost)
$username = "root"; // Database username (default: root) [Xampp]
$password = ""; // Database password (default: blank) [Xampp]
$dbname = "feedback"; // Database name (default: feedback) [Schema]
$conn = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password); // Initialises DB connection
$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
$page = (int)$_GET['p']; // XSS protection
if (!$page) {
    header("Location: ?p=1"); // Makes sure we have a page selected
}
function secondsToTime($input)
{
    $input = substr($input, 0, -1); // Chop off last digit (deciseconds to seconds)
    $minutes = ($input / 60) % 60;
    $seconds = $input % 60;
    if (strlen($minutes) == "1") {
        $minutes = "0" . $minutes;
    }
    if (strlen($seconds) == "1") {
        $seconds = "0" . $seconds;
    }
    return $minutes . ":" . $seconds;
}
?>

<head>
    <title>Tickets</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css">
    <style>
        thead th {
            position: sticky;
            top: -1;
            z-index: 10;
        }
    </style>
</head>

<body>
    <br>
    <div class="container">
        <h1>Tickets</h1>
    </div>
    <ul class="pagination">
        <?php
        if ($page > 1) {
            echo "<li class=\"page-item\"><a class=\"page-link\" href=\"./?p=" . ($page - 1) . "\">Previous</a>";
            echo "<li class=\"page-item\"><a class=\"page-link\" href=\"./?p=" . ($page - 1) . "\">" . ($page - 1) . "</a></li>";
        } else {
            echo "<li class=\"page-item\"><a class=\"page-link item-disabled\">Previous</a></li>";
        }
        echo "<li class=\"page-item active\"><a class=\"page-link\">" . $page . "</a></li>";
        echo "<li class=\"page-item\"><a class=\"page-link\" href=\"./?p=" . ($page + 1) . "\">" . ($page + 1) . "</a></li>";
        echo "<li class=\"page-item\"><a class=\"page-link\" href=\"./?p=" . ($page + 2) . "\">" . ($page + 2) . "</a></li>";
        echo "<li class=\"page-item\"><a class=\"page-link\" href=\"./?p=" . ($page + 1) . "\">Next</a></li>";
        ?>
    </ul>
    <table class="table table-dark table-bordered table-sm">
        <thead class="thead-dark text-center">
            <tr>
                <th scope="col">Roundstart Time</th>
                <th scope="col">Ticket Number</th>
                <th scope="col">Opened By (User)</th>
                <th scope="col">Open Reason</th>
                <th scope="col">Closed By (Admin)</th>
                <th scope="col">Opened At (Roundtime)</th>
                <th scope="col">Closed At (Roundtime)</th>
                <th scope="col">Open Duration (Minutes)</th>
                <th scope="col">Close State</th>
            </tr>
        </thead>
        <tbody>
            <?php
            $items_per_page = 50;
            $offset = ($items_per_page * $page) - $items_per_page;
            $stmt = $conn->prepare("SELECT * FROM tickets ORDER BY db_ticket_id DESC LIMIT ?, ?");
            $stmt->bindParam(1, $offset, PDO::PARAM_INT);
            $stmt->bindParam(2, $items_per_page, PDO::PARAM_INT);
            $stmt->execute();
            $result = $stmt->setFetchMode(PDO::FETCH_ASSOC);
            $result = $stmt->fetchAll();
            foreach ($result as $row) {
                if ($row['close_state'] == "RESOLVED") {
                    echo "<tr class=\"bg-success\">";
                }
                if ($row['close_state'] == "OPEN") {
                    echo "<tr class=\"bg-secondary\">";
                }
                if ($row['close_state'] == "STALE") {
                    echo "<tr class=\"bg-danger\">";
                }
                if ($row['close_state'] == "CLOSED") {
                    echo "<tr class=\"bg-info\">";
                }
                echo "<td>" . $row['roundstart_time'] . "</td>";
                echo "<td>" . $row['round_ticket_id'] . "</td>";
                echo "<td>" . $row['opening_ckey'] . "</td>";
                echo "<td>" . $row['initial_message'] . "</td>";
                if ($row['closing_ckey'] == "") {
                    echo "<td>Not Closed</td>";
                } else {
                    echo "<td>" . $row['closing_ckey'] . "</td>";
                }
                echo "<td>" . secondsToTime($row['opened_at']) . "</td>";
                if ($row['closed_at'] == 0) {
                    echo "<td>Not Closed</td>";
                } else {
                    echo "<td>" . secondsToTime($row['closed_at']) . "</td>";
                }
                if ($row['open_duration'] == 0) {
                    echo "<td>Not Closed</td>";
                } else {
                    echo "<td>" . secondsToTime($row['open_duration']) . "</td>";
                }
                echo "<td>" . $row["close_state"] . "</td>";
                echo "</tr>";
            }
            ?>
        </tbody>
    </table>
</body>