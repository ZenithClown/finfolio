CREATE TRIGGER user_transaction_on_update_change_timestamp BEFORE UPDATE
ON private.user_transaction FOR EACH ROW EXECUTE PROCEDURE 
onupdate_change_timestamp();
