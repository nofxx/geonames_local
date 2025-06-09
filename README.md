# Geonames Local

Downloads and store Geonames.org data locally (MongoDB, using Mongoid).
This allows you to perform Geoname API operations on your own servers with **no hit limits and maximum speed.**

## Features

- Downloads all country-specific data from Geonames.org.
- Merges ZIP code information into city data.
- Updates records using Geonames IDs to prevent duplication.
- Supports fetching alternate names in specified locales.

## Installation

1.  Install the gem:

    ```bash
    gem install geonames_local
    ```

2.  Ensure you have the following system dependencies installed:
    - `unzip`
    - `curl`

## Configuration

1.  Generate a configuration file:

    ```bash
    geonames init
    ```

    This will create a `geonames.yml` file in your current directory.

2.  Edit `geonames.yml` to suit your environment. Key settings include:

    - `store`: The database adapter to use (currently defaults to `mongodb`).
    - `db`: Database connection details for MongoDB:
      - `host`: MongoDB host and port (e.g., `localhost:27017`).
      - `name`: Database name (e.g., `geonames_local`).
      - `username` (optional): Username for MongoDB authentication.
      - `password` (optional): Password for MongoDB authentication.
      - `clean` (optional, boolean): If `true`, drops the database collections before import.
    - `locales`: An array of locale codes (e.g., `['en', 'pt', 'es']`) for which to download alternate names. The first locale in the list is typically considered the primary.
    - `min_pop`: Minimum population for a city to be imported.
    - `verbose`: Set to `true` for detailed logging output.
    - `tmp_dir` (optional): Path to a directory for temporary download files (defaults to `/tmp/geonames/`).

    The gem populates a separate `nations` collection automatically with data for approximately 252 nations.

## Usage

### Basic Import

To import Geonames data using your configuration file:

```bash
geonames -c geonames.yml
```

For verbose output, add the `-v` flag:

```bash
geonames -v -c geonames.yml
```

### Specifying Target Nations

You can specify one or more nation codes (ISO 3166-1 alpha-2) to import data only for those nations. If no nations are specified, it defaults to importing data for all nations defined in `Opt[:nations]` in your config, or all available if not specified.

```bash
geonames BR US -c geonames.yml # Import data for Brazil and USA
```

### Listing Nation Codes

If you are unsure of a country's code, you can search for it:

```bash
geonames list <search_term>
# Example: geonames list brazil
```

### Cleaning the Database

To clean (drop collections) the database before an import, you can either:

1.  Set `clean: true` under the `db` section in your `geonames.yml`.
2.  Use the `-d` or `--dump` flag (though this seems to be an alias for clean in the current CLI):
    ```bash
    geonames -d -c geonames.yml
    ```

### Exporting Data

The CLI has an option for exporting data, though the implementation details might need review:

```bash
geonames csv -c geonames.yml # Attempt to export Nation data to CSV
```

### Data Updates

The import process uses Geonames IDs (`gid`) as unique identifiers. When re-importing data, existing records with the same `gid` are updated, and new records are created. This helps in keeping your local data synchronized with Geonames.org updates without creating duplicates.

## Models (via Geopolitical Gem)

This gem utilizes models from the [geopolitical](https://github.com/fireho/geopolitical) gem when interacting with MongoDB. This allows for rich object interactions, for example:

```ruby
City.first.region.nation.abbr
# => "BR"
```

## Running Tests

_(Placeholder: Instructions on how to set up the test environment and run tests will be added here once tests are implemented.)_

## Future Enhancements

- Import IP-based Geolocation data (e.g., from ipinfodb.com).
- Import neighborhood (hood) data from sources like IBGE for Brazil.
- Support for ActiveRecord/PostGIS as an alternative data store.
- More comprehensive test suite.
- Improved error handling and logging.
