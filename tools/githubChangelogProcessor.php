<?php
/*
 *	Github webhook In-game PR Announcer and SQL Changelog Generator for ParadiseSS13
 *  Modified for Paradise by: AffectedArc07
 *	Original code by: MrStonedOne
 *
 *	For documentation on the changelog generator see https://tgstation13.org/phpBB/viewtopic.php?f=5&t=5157
 *	To hide prs from being announced in game, place a [s] in front of the title
 *	All runtime errors are echo'ed to the webhook's logs in github
 */

/**CREDITS:
 * GitHub webhook handler template.
 *
 * @see  https://developer.github.com/webhooks/
 * @author  Miloslav Hula (https://github.com/milo)
 */


//CONFIG START (all defaults are random examples, do change them)
//Use single quotes for config options that are strings.

//Github lets you have it sign the message with a secret that you can validate. This prevents people from faking events.
//This var should match the secret you configured for this webhook on github.
//This is required as otherwise somebody could trick the script into leaking variables.
$hookSecret = '08ajh0qj93209qj90jfq932j32r';

// To store PR changelogs, this script requires access to the game database
// Making an account just for this service is highly recommended
// For maximum security, grant it INSERT on `changelog` ONLY.
$dbServer = "localhost"; // Hostname of the database server (default localhost)
$dbPort = "3306"; // Port of the database server (default 3306) | MUST BE A STRING
$dbUser = "root"; // Database username (default root)
$dbPassword = ""; // Database password (default blank)
$dbDatabase = "paradise_gamedb"; // Database name (default paradise_gamedb)

//servers to announce PRs to.
$servers = array();
/*
$servers[0] = array();
$servers[0]['address'] = 'game.tgstation13.org';
$servers[0]['port'] = '1337';
$servers[0]['comskey'] = '89aj90cq2fm0amc90832mn9rm90';
$servers[1] = array();
$servers[1]['address'] = 'game.tgstation13.org';
$servers[1]['port'] = '2337';
$servers[1]['comskey'] = '89aj90cq2fm0amc90832mn9rm90';
*/

//CONFIG END
set_error_handler(function($severity, $message, $file, $line) {
	throw new \ErrorException($message, 0, $severity, $file, $line);
});
set_exception_handler(function($e) {
	header('HTTP/1.1 500 Internal Server Error');
	echo "Error on line {$e->getLine()}: " . htmlSpecialChars($e->getMessage());
	die();
});
$rawPost = NULL;
if (!$hookSecret || $hookSecret == '08ajh0qj93209qj90jfq932j32r')
	throw new \Exception("Hook secret is required and can not be default");
if (!isset($_SERVER['HTTP_X_HUB_SIGNATURE'])) {
	throw new \Exception("HTTP header 'X-Hub-Signature' is missing.");
} elseif (!extension_loaded('hash')) {
	throw new \Exception("Missing 'hash' extension to check the secret code validity.");
}
list($algo, $hash) = explode('=', $_SERVER['HTTP_X_HUB_SIGNATURE'], 2) + array('', '');
if (!in_array($algo, hash_algos(), TRUE)) {
	throw new \Exception("Hash algorithm '$algo' is not supported.");
}
$rawPost = file_get_contents('php://input');
if ($hash !== hash_hmac($algo, $rawPost, $hookSecret)) {
	throw new \Exception('Hook secret does not match.');
}

$contenttype = null;
//apache and nginx/fastcgi/phpfpm call this two different things.
if (!isset($_SERVER['HTTP_CONTENT_TYPE'])) {
	if (!isset($_SERVER['CONTENT_TYPE']))
		throw new \Exception("Missing HTTP 'Content-Type' header.");
	else
		$contenttype = $_SERVER['CONTENT_TYPE'];
} else {
	$contenttype = $_SERVER['HTTP_CONTENT_TYPE'];
}
if (!isset($_SERVER['HTTP_X_GITHUB_EVENT'])) {
	throw new \Exception("Missing HTTP 'X-Github-Event' header.");
}
switch ($contenttype) {
	case 'application/json':
		$json = $rawPost ?: file_get_contents('php://input');
		break;
	case 'application/x-www-form-urlencoded':
		$json = $_POST['payload'];
		break;
	default:
		throw new \Exception("Unsupported content type: $contenttype");
}
# Payload structure depends on triggered event
# https://developer.github.com/v3/activity/events/types/
$payload = json_decode($json, true);

switch (strtolower($_SERVER['HTTP_X_GITHUB_EVENT'])) {
	case 'ping':
		echo 'pong';
		break;
	case 'pull_request':
		handle_pr($payload);
		break;
	default:
		header('HTTP/1.0 404 Not Found');
		echo "Event:$_SERVER[HTTP_X_GITHUB_EVENT] Payload:\n";
		print_r($payload); # For debug only. Can be found in GitHub hook log.
		die();
}
function handle_pr($payload) {
	$action = 'opened';
	switch ($payload["action"]) {
		case 'opened':
		case 'reopened':
			$action = $payload['action'];
			break;
		case 'closed':
			if (!$payload['pull_request']['merged']) {
				$action = 'closed';
			}
			else {
				$action = 'merged';
				checkchangelog($payload, true);
			}
			break;
		default:
			return;
	}

	if (strtolower(substr($payload['pull_request']['title'], 0, 3)) == '[s]') {
		echo "PR Announcement Halted; Secret tag detected.\n";
		return;
	}

	$msg = 'Pull Request '.$action.' by '.htmlSpecialChars($payload['sender']['login']).': <a href="'.$payload['pull_request']['html_url'].'">'.htmlSpecialChars('#'.$payload['pull_request']['number'].' '.$payload['pull_request']['user']['login'].' - '.$payload['pull_request']['title']).'</a>';
	sendtoallservers('?announce='.urlencode($msg));

}

function checkchangelog($payload, $merge = false) {
	global $dbServer, $dbUser, $dbPassword, $dbDatabase, $dbPort;
	if (!$merge)
		return;
	if (!isset($payload['pull_request']) || !isset($payload['pull_request']['body'])) {
		return;
	}
	if (!isset($payload['pull_request']['user']) || !isset($payload['pull_request']['user']['login'])) {
		return;
	}
	$body = $payload['pull_request']['body'];
	$prNumber = $payload['pull_request']['number'];
	$body = str_replace("\r\n", "\n", $body);
	$body = explode("\n", $body);
	$username = $payload['pull_request']['user']['login'];
	$incltag = false;
	$changelogbody = array();
	$currentchangelogblock = array();
	$foundcltag = false;
	foreach ($body as $line) {
		$line = trim($line);
		if (substr($line,0,4) == ':cl:' || substr($line,0,4) == '🆑') {
			$incltag = true;
			$foundcltag = true;
			$pos = strpos($line, " ");
			if ($pos)
				$username = substr($line, $pos+1);
			continue;
		} else if (substr($line,0,5) == '/:cl:' || substr($line,0,6) == '/ :cl:' || substr($line,0,5) == ':/cl:' || substr($line,0,5) == '/🆑' || substr($line,0,6) == '/ 🆑' ) {
			$incltag = false;
			$changelogbody = array_merge($changelogbody, $currentchangelogblock);
			continue;
		}
		if (!$incltag)
			continue;

		$firstword = explode(' ', $line)[0];
		$pos = strpos($line, " ");
		$item = '';
		if ($pos) {
			$firstword = trim(substr($line, 0, $pos));
			$item = trim(substr($line, $pos+1));
		} else {
			$firstword = $line;
		}

		if (!strlen($firstword)) {
			$currentchangelogblock[count($currentchangelogblock)-1]['body'] .= "\n";
			continue;
		}
		//not a prefix line.
		//so we add it to the last changelog entry as a separate line
		if (!strlen($firstword) || $firstword[strlen($firstword)-1] != ':') {
			if (count($currentchangelogblock) <= 0)
				continue;
			$currentchangelogblock[count($currentchangelogblock)-1]['body'] .= "\n".$line;
			continue;
		}
		$cltype = strtolower(substr($firstword, 0, -1));
		switch ($cltype) {
			case 'fix':
			case 'fixes':
			case 'bugfix':
				$currentchangelogblock[] = array('type' => 'FIX', 'body' => $item);
				break;
			case 'wip':
				$currentchangelogblock[] = array('type' => 'WIP', 'body' => $item);
				break;
			case 'rsctweak':
			case 'tweaks':
			case 'tweak':
				$currentchangelogblock[] = array('type' => 'TWEAK', 'body' => $item);
				break;
			case 'soundadd':
				$currentchangelogblock[] = array('type' => 'SOUNDADD', 'body' => $item);
				break;
			case 'sounddel':
				$currentchangelogblock[] = array('type' => 'SOUNDDEL', 'body' => $item);
				break;
			case 'add':
			case 'adds':
			case 'rscadd':
				$currentchangelogblock[] = array('type' => 'CODEADD', 'body' => $item);
				break;
			case 'del':
			case 'dels':
			case 'rscdel':
				$currentchangelogblock[] = array('type' => 'CODEDEL', 'body' => $item);
				break;
			case 'imageadd':
				$currentchangelogblock[] = array('type' => 'IMAGEADD', 'body' => $item);
				break;
			case 'imagedel':
				$currentchangelogblock[] = array('type' => 'IMAGEDEL', 'body' => $item);
				break;
			case 'typo':
			case 'spellcheck':
				$currentchangelogblock[] = array('type' => 'SPELLCHECK', 'body' => $item);
				break;
			case 'experimental':
			case 'experiment':
				$currentchangelogblock[] = array('type' => 'EXPERIMENT', 'body' => $item);
				break;
			default:
				//we add it to the last changelog entry as a separate line
				if (count($currentchangelogblock) > 0)
					$currentchangelogblock[count($currentchangelogblock)-1]['body'] .= "\n".$line;
				break;
		}
	}


	if (!count($changelogbody))
		return;

	$conn = new PDO("mysql:host=$dbServer;dbname=$dbDatabase;port=$dbPort", $dbUser, $dbPassword); // Initialises DB connection
	$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

	foreach($changelogbody as $changelogEntry) {
		// Throw all changelogs into the DB
		$stmt = $conn->prepare("INSERT INTO changelog (pr_number, author, cl_type, cl_entry) VALUES (?, ?, ?, ?)");
		$stmt->bindParam(1, $prNumber, PDO::PARAM_INT);
		$stmt->bindParam(2, $username, PDO::PARAM_STR);
		$stmt->bindParam(3, $changelogEntry["type"], PDO::PARAM_STR);
		$stmt->bindParam(4, $changelogEntry["body"], PDO::PARAM_STR);
		$stmt->execute();
	}

	$conn = null; // Close the DB connection

}

function sendtoallservers($str) {
	global $servers;
	foreach ($servers as $serverid => $server) {
		if (isset($server['comskey']))
			$rtn = export($server['address'], $server['port'], $str.'&key='.$server['comskey']);
		else
			$rtn = export($server['address'], $server['port'], $str);

		echo "Server Number $serverid replied: $rtn\n";
	}
}



function export($addr, $port, $str) {
	global $error;
	// All queries must begin with a question mark (ie "?players")
	if($str{0} != '?') $str = ('?' . $str);

	/* --- Prepare a packet to send to the server (based on a reverse-engineered packet structure) --- */
	$query = "\x00\x83" . pack('n', strlen($str) + 6) . "\x00\x00\x00\x00\x00" . $str . "\x00";

	/* --- Create a socket and connect it to the server --- */
	$server = socket_create(AF_INET,SOCK_STREAM,SOL_TCP) or exit("ERROR");
	socket_set_option($server, SOL_SOCKET, SO_SNDTIMEO, array('sec' => 2, 'usec' => 0)); //sets connect and send timeout to 2 seconds
	if(!socket_connect($server,$addr,$port)) {
		$error = true;
		return "ERROR";
	}


	/* --- Send bytes to the server. Loop until all bytes have been sent --- */
	$bytestosend = strlen($query);
	$bytessent = 0;
	while ($bytessent < $bytestosend) {
		//echo $bytessent.'<br>';
		$result = socket_write($server,substr($query,$bytessent),$bytestosend-$bytessent);
		//echo 'Sent '.$result.' bytes<br>';
		if ($result===FALSE) die(socket_strerror(socket_last_error()));
		$bytessent += $result;
	}

	/* --- Idle for a while until received bytes from game server --- */
	$result = socket_read($server, 10000, PHP_BINARY_READ);
	socket_close($server); // we don't need this anymore

	if($result != "") {
		if($result{0} == "\x00" || $result{1} == "\x83") { // make sure it's the right packet format

			// Actually begin reading the output:
			$sizebytes = unpack('n', $result{2} . $result{3}); // array size of the type identifier and content
			$size = $sizebytes[1] - 1; // size of the string/floating-point (minus the size of the identifier byte)

			if($result{4} == "\x2a") { // 4-byte big-endian floating-point
				$unpackint = unpack('f', $result{5} . $result{6} . $result{7} . $result{8}); // 4 possible bytes: add them up together, unpack them as a floating-point
				return $unpackint[1];
			}
			else if($result{4} == "\x06") { // ASCII string
				$unpackstr = ""; // result string
				$index = 5; // string index

				while($size > 0) { // loop through the entire ASCII string
					$size--;
					$unpackstr .= $result{$index}; // add the string position to return string
					$index++;
				}
				return $unpackstr;
			}
		}
	}
	//if we get to this point, something went wrong;
	$error = true;
	return "ERROR";
}
