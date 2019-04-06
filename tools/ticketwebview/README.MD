# Ticket Web Viewer

In this folder you will find the files for a PHP based ticket viewing frontend, to simplify ticket viewing. It shows the most recent tickets first, and shows 50 per page

To set this up, open `index.php` in a text editor and edit the following lines to configure for your database. A read-only database account is recommended

```php
4]  $servername = "localhost"; // Hostname of the database server (default localhost)
5]  $username = "root"; // Database username (default: root) [Xampp]
6]  $password = ""; // Database password (default: blank) [Xampp]
7]  $dbname = "feedback"; // Database name (default: feedback) [Schema]
```

After that, simply open the page in any web browser. To protect against random people finding the URL, I recommend setting a HTPassword