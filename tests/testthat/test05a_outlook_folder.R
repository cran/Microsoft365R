tenant <- "consumers"
app <- Sys.getenv("AZ_TEST_NATIVE_APP_ID")

if(app == "")
    skip("Outlook folder tests skipped: Microsoft Graph credentials not set")

if(!interactive())
    skip("Outlook folder tests skipped: must be in interactive session")

tok <- get_test_token(tenant, app, c("Mail.Send", "Mail.ReadWrite", "User.Read"))
if(is.null(tok))
    skip("Outlook tests skipped: unable to login to consumers tenant")

inbox <- try(call_graph_endpoint(tok, "me/mailFolders/inbox"), silent=TRUE)
if(inherits(inbox, "try-error"))
    skip("Outlook tests skipped: service not available")

outl <- get_personal_outlook(token=tok)

test_that("Outlook folder methods work",
{
    expect_is(outl, c("ms_outlook", "ms_outlook_object"))

    fname <- make_name()
    folder <- outl$create_folder(fname)
    expect_is(folder, c("ms_outlook_folder", "ms_outlook_object"))

    e1 <- folder$create_email("test email 1", subject="test email 1")
    Sys.sleep(1)
    e2 <- folder$create_email("test email 2", subject="test email 2")
    Sys.sleep(1)
    e3 <- folder$create_email("test email 3", subject="test email 3")

    e11 <- folder$get_email(e1$properties$id)
    expect_is(e11, "ms_outlook_email")
    expect_identical(e11$properties$id, e1$properties$id)

    get_subj <- function(email) email$properties$subject
    get_recv <- function(email) email$properties$receivedDateTime

    expect_silent(lst1 <- folder$list_emails())
    expect_is(lst1, "list")
    expect_true(all(sapply(lst1, inherits, "ms_outlook_email")))
    expect_true(get_recv(lst1[[1]]) == get_recv(e3) &&
                get_recv(lst1[[2]]) == get_recv(e2) &&
                get_recv(lst1[[3]]) == get_recv(e1))

    expect_silent(lst2 <- folder$list_emails(by="received"))  # sorting by reverse of default order
    expect_true(get_recv(lst2[[1]]) == get_recv(e1) &&
                get_recv(lst2[[2]]) == get_recv(e2) &&
                get_recv(lst2[[3]]) == get_recv(e3))

    expect_silent(lst3 <- folder$list_emails(by=c("subject desc", "from")))  # sorting by multiple fields
    expect_true(get_subj(lst3[[1]]) == get_subj(e3) &&
                get_subj(lst3[[2]]) == get_subj(e2) &&
                get_subj(lst3[[3]]) == get_subj(e1))

    expect_error(folder$list_emails(by="reply_to"))  # unsupported field

    lst4 <- folder$list_emails(search="email 3")
    expect_is(lst4, "list")
    expect_true(length(lst4) == 1 && inherits(lst4[[1]], "ms_outlook_email"))

    subj1 <- e1$properties$subject
    empager <- folder$list_emails(filter=sprintf("subject eq '%s'", subj1), n=NULL)
    expect_is(empager, "ms_graph_pager")
    lst5 <- empager$value
    expect_true(length(lst5) == 1 && inherits(lst5[[1]], "ms_outlook_email"))

    expect_silent(folder$delete_email(e11$properties$id, confirm=FALSE))

    fname2 <- make_name()
    folder$create_folder(fname2)
    folder2 <- folder$get_folder(fname2)
    expect_is(folder2, "ms_outlook_folder")

    flist <- folder$list_folders()
    expect_is(flist, "list")
    expect_true(all(sapply(flist, inherits, "ms_outlook_folder")))

    f1 <- flist[[1]]$properties$displayName
    fpager <- outl$list_folders(filter=sprintf("displayName eq '%s'", f1), n=NULL)
    expect_is(fpager, "ms_graph_pager")
    flist1 <- fpager$value
    expect_true(length(flist1) ==1 && inherits(flist1[[1]], "ms_outlook_folder"))

    expect_silent(folder$delete_folder(fname2, confirm=FALSE))
    expect_silent(folder$delete(confirm=FALSE))
})

