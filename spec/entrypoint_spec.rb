# frozen_string_literal: true

require 'open3'
require 'tmpdir'

# The Docker image runs everything through entrypoint.sh. It used to build a
# single string out of "$@" and hand it to `sh -c`, which parsed the arguments a
# SECOND time and ate the quotes, so
#   heighliner set cert-1password-fields '{"key":"privkey"}'
# arrived as {key:privkey} and blew up in JSON.parse. These specs run the real
# entrypoint against a stub `heighliner` that prints its argv.
RSpec.describe 'entrypoint.sh' do
  let(:entrypoint) { File.expand_path('../entrypoint.sh', __dir__) }

  # Runs entrypoint.sh with a stub `heighliner` first on PATH, and returns the
  # argv the stub actually received, one element per line.
  def run_entrypoint(*args)
    Dir.mktmpdir do |bindir|
      stub = File.join(bindir, 'heighliner')
      File.write(stub, <<~STUB)
        #!/bin/sh
        for a in "$@"; do echo "$a"; done
      STUB
      FileUtils.chmod(0o755, stub)

      out, err, status = Open3.capture3(
        { 'PATH' => "#{bindir}:#{ENV.fetch('PATH')}", 'CONTEXT_DIR' => bindir },
        'sh', entrypoint, *args
      )
      raise "entrypoint failed: #{err}" unless status.success?

      out.lines.map(&:chomp)
    end
  end

  it 'passes a JSON argument through without touching the quotes' do
    json = '{"key":"privkey","crt":"fullchain","chain.pem":"chain"}'

    expect(run_entrypoint('set', 'cert-1password-fields', json))
      .to eq(['set', 'cert-1password-fields', json])
  end

  it 'keeps an argument containing spaces as one argument' do
    expect(run_entrypoint('login', 'bash', '-c', 'ls -la /tmp'))
      .to eq(['login', 'bash', '-c', 'ls -la /tmp'])
  end

  it 'does not glob or expand arguments' do
    expect(run_entrypoint('set', 'http-suffix', '*')).to eq(['set', 'http-suffix', '*'])
  end

  it 'runs in the context directory' do
    Dir.mktmpdir do |dir|
      real = File.realpath(dir)
      stub = File.join(dir, 'heighliner')
      File.write(stub, "#!/bin/sh\npwd\n")
      FileUtils.chmod(0o755, stub)

      out, = Open3.capture3(
        { 'PATH' => "#{dir}:#{ENV.fetch('PATH')}", 'CONTEXT_DIR' => real },
        'sh', entrypoint, 'show', 'ports'
      )

      expect(out.chomp).to eq(real)
    end
  end
end
