/********************************************************************
A Simple Call to Stored Procedures to Update Transfer Methods

The following call to stored procedures updates transfer methods to
user's transaction records. In addition, each is associated with a
function call and can be used as a dry run to find which records are
going to be updated.
********************************************************************/

-- ? cash transaction method
SELECT * FROM public.udf_pattern_filter_for_transfer_method('%ATM%CASH%');
CALL public.usp_set_transfer_method('CASH', '%ATM%CASH%');

-- ? neft transaction method
SELECT * FROM public.udf_pattern_filter_for_transfer_method('%NEFT%');
CALL public.usp_set_transfer_method('NEFT', '%NEFT%');

-- ? imps transaction method
SELECT * FROM public.udf_pattern_filter_for_transfer_method('%IMPS%');
CALL public.usp_set_transfer_method('IMPS', '%IMPS%');

-- ? upi transaction method
SELECT * FROM public.udf_pattern_filter_for_transfer_method('%TRANSFER%UPI%');
CALL public.usp_set_transfer_method('UPI', '%TRANSFER%UPI%');

-- ? mandate transaction method
SELECT * FROM public.udf_pattern_filter_for_transfer_method('%MANDATE%');
CALL public.usp_set_transfer_method('MANDATE', '%MANDATE%');
