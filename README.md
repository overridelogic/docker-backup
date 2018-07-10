# docker-backup

Container image that generate volume backups either when started or on a specific run schedule.

`docker-backup` is an automation container image that automatically backs up docker volumes to a specific location, either locally, or on Amazon S3. It can be run on a machine running docker to automatically back up either all volumes or specific ones, in real-time or on a specific schedule.

## Running the image

To run the backup process:

    docker run --rm \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v <output-dir>:/data \
        overridelogic/docker-backup

This will back up all used volumes to the **output-dir** directory.

### Running on a schedule

If you want to run the backup process on a specific schedule, you can specify at runtime. The container will keep running in the background, running the backups at the specified times:

    docker run --rm -d \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v <output-dir>:/data \
        -e SCHEDULE="* */6 * * *" \
        overridelogic/docker-backup

The above will backup all volumes to the specified output directory every 6 hours.

### Backing up specific volumes

You can specify the `VOLUMES` environment variable to select which volumes to backup:

    docker run --rm -d \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v <output-dir>:/data \
        -e SCHEDULE="* */6 * * *" \
        -e VOLUMES="foo-data bar-data" \
        overridelogic/docker-backup

The above will backup only `foo-data` and `bar-data` every 6 hours.

### Upload to S3

You can have the script automatically upload the backups to an S3 bucket:

    docker run --rm \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v <output-dir>:/data \                             # optional
        -e S3_BUCKET="my-s3-bucket" \                       # required
        -e S3_PREFIX="/my-bucket-path/" \                   # optional
        -e S3_ENABLETAG=0 \                                 # see below
        -e S3_OPTS="--access-key=foo --secret-key bar" \    # see below
        overridelogic/docker-backup

The following environment variables are supported:

 - `S3_BUCKET`: the name of the bucket to save to.
 - `S3_PREFIX`: the prefix, i.e.: path, within the bucket to upload to.
 - `S3_ENABLELATEST`: if enabled (default), automatically creates or upadtes a file with the `-latest` suffix whenever a new backup file is created. There is only one `-latest` file per volume, it will get updated at every run. If disabled, the *"latest"* file will simply not be created or updated.
 - `S3_OPTS`: additional options to pass to *s3cmd*. Typically here, you need to pass either `--access-key` and `--secret-key` or an `--access-token` argument.

## Contributing

Contributions are always welcome. Please fork on GitHub and submit a pull request.

- Upstream: http://gogs.overridelogic.io/devops/docker-backup/
- Github: https://github.com/overridelogic/docker-backup/
- Docker Hub: https://hub.docker.com/r/overridelogic/docker-backup/

## Building the image

Simply run:

    docker build . -t docker-backup:<tag>

## License

This work is licensed under the GNU Generic Public License v3, bundled with this program.

## Author(s)

Created by *Francis Lacroix* (*@netcoder1*) while at **OverrideLogic**.
