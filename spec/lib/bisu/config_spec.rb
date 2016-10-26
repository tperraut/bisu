describe Bisu::Config do
  subject(:config) { Bisu::Config.new(file: file_path) }

  context "given a yml file" do
    let(:file_path) { "spec/fixtures/sample_translatable.yml" }

    it "should parse the yml with deep key symbolization" do
      expect(config.to_h).to eq({
        type:        "BisuOS",
        sheet_id:    "abc1234567890",
        keys_column: "key_name",
        in:          [
          "path/to/file/to/1.ext.translatable",
          "path/to/file/to/2.ext.translatable"
        ],
        out_path:    "path/to/final-%{locale}/%{out_name}",
        out:         [
          { locale: "en",    kb_language: "english", path: "path/to/default/%{out_name}" },
          { locale: "pt",    kb_language: "portuguese" },
          { locale: "pt-PT", kb_language: "portuguese" }
        ]
      })
    end
  end

  context "given an inexistent file" do
    let(:file_path) { "does_not_exist" }
    it { expect { config }.to raise_error /does not exist/ }
  end

  context "given no file path" do
    let(:file_path) { nil }
    it { expect { config }.to raise_error /expected String/ }
  end
end
