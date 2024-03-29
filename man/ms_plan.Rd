% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ms_plan.R
\docType{class}
\name{ms_plan}
\alias{ms_plan}
\title{Microsoft Planner Plan}
\format{
An R6 object of class \code{ms_plan}, inheriting from \code{ms_object}.
}
\description{
Class representing one plan withing a Microsoft Planner.
}
\details{
The plans belong to a group.
}
\section{Fields}{

\itemize{
\item \code{token}: The token used to authenticate with the Graph host.
\item \code{tenant}: The Azure Active Directory tenant for this drive.
\item \code{type}: always "plan" for plan object.
\item \code{properties}: The plan properties.
}
}

\section{Methods}{

\itemize{
\item \code{new(...)}: Initialize a new plan object. Do not call this directly; see 'Initialization' below.
\item \code{update(...)}: Update the plan metadata in Microsoft Graph.
\item \code{do_operation(...)}: Carry out an arbitrary operation on the plan
\item \code{sync_fields()}: Synchronise the R object with the plan metadata in Microsoft Graph.
\item \code{list_tasks(filter=NULL, n=Inf)}: List the tasks under the specified plan.
\item \code{get_task(task_title, task_id)}: Get a task, either by title or ID.
\item \code{list_buckets(filter=NULL, n=Inf)}: List the buckets under the specified plan.
\item \code{get_bucket(bucket_name, bucket_id)}: Get a bucket, either by name or ID.
\item \code{get_details()}: Get the plan details.
}
}

\section{Initialization}{

Creating new objects of this class should be done via the \code{list_plans} methods of the \code{\link{az_group}} class.
Calling the \code{new()} method for this class only constructs the R object; it does not call the Microsoft Graph API to retrieve or create the actual plan.
}

\section{Planner operations}{

This class exposes methods for carrying out common operations on a plan. Currently only read operations are supported.

Call \code{list_tasks()} to list the tasks under the plan, and \code{get_task()} to retrieve a specific task. Similarly, call \code{list_buckets()} to list the buckets, and \code{get_bucket()} to retrieve a specific bucket.

Call \code{get_details()} to get a list containing the details for the plan.
}

\section{List methods}{

All \verb{list_*} methods have \code{filter} and \code{n} arguments to limit the number of results. The former should be an \href{https://learn.microsoft.com/en-us/graph/query-parameters#filter-parameter}{OData expression} as a string to filter the result set on. The latter should be a number setting the maximum number of (filtered) results to return. The default values are \code{filter=NULL} and \code{n=Inf}. If \code{n=NULL}, the \code{ms_graph_pager} iterator object is returned instead to allow manual iteration over the results.

Support in the underlying Graph API for OData queries is patchy. Not all endpoints that return lists of objects support filtering, and if they do, they may not allow all of the defined operators. If your filtering expression results in an error, you can carry out the operation without filtering and then filter the results on the client side.
}

\seealso{
\code{\link{ms_plan_task}}, \code{\link{ms_plan_bucket}}

\href{https://learn.microsoft.com/en-us/graph/overview}{Microsoft Graph overview},
\href{https://learn.microsoft.com/en-us/graph/api/resources/planner-overview?view=graph-rest-beta}{Plans overview}
}
