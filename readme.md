# Sow

You can only reap what you sow in any Harvest. For the CLI junkies, waiting for a
web page to load and react can be frustrating. Sow helps relieve that frustration
by making it possible to interact with Harvest without needing to wait on the web
UI. Hopefully, this will help you sow faster and reap more in Harvest!

## Installation

    $ npm install -g sow


## Usage

Sow focuses on time entry and history. Its aim is to make it easy to do CRUD-like
actions on time tracking, and produce some very simple reports all from the CLI.
Most commands have a shortcut as well to make usage as fast as possible.

For all date fields, you can use any normal date formats parsed by JavaScript's
Date class. Additionally, you can use any kind of natural language (e.g.
"yesterday", "last Tuesday"). Any natural language date expressions which contain
spaces must be enclosed in quotation marks.


### alias [a]

Create an alias for a resource. Aliases can be created for clients, projects, and
tasks
The alias must be unique for its type and cannot
contain dots (.).
The client parameter can be either the client ID (if known) or a string for
searching. If multiple matches are found, they will be provided as options from
which you can choose the correct client.

Parameters: [--type = project] alias resource


### Time Entry

* log [l]

    Create a new inactive timer.

    Parameters: project(.| )task time [comment]

* start [s]

    Create a new active timer, optionally adding time to it.

    Parameters: project(.| )task [time] [comment]

* pause [p]

    Pause the active timer.

* resume [r]

    Continue an existing timer.

    Parameters: project(.| )task [comment]

* note [n]

    Updates the note for the currently running timer.

    Parameters: note


### Time Reporting

*  day [d]

    Summary provides, as may be expected, a summary of a day's entries. If a date
    is not provided, sow will default to today.

    Parameters: [date]

        $ sow day            // Today's entries
        $ sow d 2012-12-01   // 01 Dec 2012
        $ sow day 11/11/2011 // 11 Nov 2011
        $ sow d 7.11.2013    // 11 July 2013

* week [w]

    Provides a summary of all entries within a set week. The default date is
    today. The result will be for the week in which the provided date exists.

    Parameters: [date]

* range

    Provides a summary of all entries within a range of dates.

    Parameters: fromDate toDate


## Configuration

### startOfWeek

Defines the day on which the week starts. Default is Monday.
