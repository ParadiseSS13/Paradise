# Updating DB from 18-19, -AffectedArc07
# Finalises feedback2

# Drop old feedback table
DROP TABLE `feedback`;

# Rename feedback_2 to feedback
RENAME TABLE `feedback_2` TO `feedback`;
