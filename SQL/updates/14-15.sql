# Updating DB from 14-15, -AffectedArc07
# Removes player poll tables which were never used
DROP TABLE `poll_option`;
DROP TABLE `poll_question`;
DROP TABLE `poll_textreply`;
DROP TABLE `poll_vote`;