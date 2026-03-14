# frozen_string_literal: true

require 'legion/extensions/cognitive_narrative_arc/client'

RSpec.describe Legion::Extensions::CognitiveNarrativeArc::Client do
  it 'responds to all narrative runner methods' do
    client = described_class.new
    expect(client).to respond_to(:create_arc)
    expect(client).to respond_to(:add_beat)
    expect(client).to respond_to(:get_arc)
    expect(client).to respond_to(:active_arcs)
    expect(client).to respond_to(:completed_arcs)
    expect(client).to respond_to(:most_dramatic_arc)
    expect(client).to respond_to(:arc_report)
  end

  it 'initializes with an arc engine' do
    client = described_class.new
    result = client.arc_report
    expect(result[:report][:total_arcs]).to eq(0)
  end
end
