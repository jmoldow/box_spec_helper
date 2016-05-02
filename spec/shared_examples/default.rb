shared_examples 'default' do |*args|
  if args.empty?
    context 'default' do
      it { should compile.with_all_deps }
    end
  end
end
